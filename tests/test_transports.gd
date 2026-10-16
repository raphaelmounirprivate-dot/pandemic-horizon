extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Transport = preload("res://scripts/gameplay/transports.gd")
const Store = preload("res://scripts/persistence/save_store.gd")

func run(tree: SceneTree, check: Callable) -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH))
	var catalog = World.Scenarios.load_catalog()
	var config = Transport.load_file()
	check.call(Transport.validate(config, data, catalog).is_empty(), "Transports livrés valides")
	var model = World.new()
	model.start("boreale")
	for edge in model.connections:
		check.call(model.route_mode(edge) in Transport.MODES and model.route_mode(edge) == model.route_mode([edge[1], edge[0]]), "Type symétrique et défini : " + Transport.key(edge))
	for mutation in ["root", "version", "profiles", "coefficient", "nan", "missing", "duplicate", "reverse", "unknown", "mode", "season", "edge"]:
		var bad: Variant = config.duplicate(true)
		match mutation:
			"root": bad = []
			"version": bad.schema_version = 99
			"profiles": bad.profiles.erase("air")
			"coefficient": bad.profiles.air = 0
			"nan": bad.profiles.air = NAN
			"missing": bad.routes.pop_back()
			"duplicate": bad.routes.append(bad.routes[0].duplicate(true))
			"reverse":
				var reverse = bad.routes[0].duplicate(true)
				reverse.edge.reverse()
				bad.routes.append(reverse)
			"unknown": bad.routes[0].edge = ["absent", "centrale"]
			"mode": bad.routes[0].mode = "space"
			"season": bad.routes[1].mode = "land"
			"edge": bad.routes[0].edge = ["boreale"]
		check.call(not Transport.validate(bad, data, catalog).is_empty(), "Transport invalide rejeté : " + mutation)
		var before = model.regions.duplicate(true)
		check.call(not model.start("boreale", 2042, null, null, "standard", "normal", null, bad).is_empty() and model.regions == before, "Démarrage invalide conserve le monde : " + mutation)
	# Imported cases are read from the pre-step snapshot; local growth starts later.
	for fixture in [{"start":"boreale", "target":"occident", "expected":10}, {"start":"centrale", "target":"meridien", "expected":12}, {"start":"boreale", "target":"centrale", "expected":8}]:
		model.start(fixture.start)
		for region in model.regions:
			if region.id == fixture.start:
				region.active = 10000
				region.healthy = int(region.population) - 10000
		model.step()
		for region in model.regions:
			if region.id == fixture.target: check.call(region.active == fixture.expected, "Import réel par type : " + fixture.target)
	var content = World.Content.load_files()
	content.events.events = [
		{"id":"air_a","name":"Air A","kind":"transport_multiplier","start_day":1,"duration":2,"target":"air","factor":0.5},
		{"id":"air_b","name":"Air B","kind":"transport_multiplier","start_day":2,"duration":2,"target":"air","factor":0.5},
		{"id":"closed","name":"Fermeture","kind":"route_closure","start_day":2,"duration":1,"target":["centrale","meridien"],"factor":1.0}]
	model.start("boreale", 2042, data, content, "standard", "normal", catalog, config)
	model.step()
	check.call(is_equal_approx(model.transport_factor(["centrale", "meridien"]), 0.6), "Ralentissement aérien appliqué")
	check.call(is_equal_approx(model.transport_factor(["boreale", "occident"]), 1) and is_equal_approx(model.transport_factor(["boreale", "centrale"]), 0.8), "Autres types inchangés")
	model.step()
	check.call(model.transport_factor(["centrale", "meridien"]) == 0 and is_equal_approx(model.event_modifier("transport_multiplier", "air"), 0.25), "Fermeture prioritaire sur ralentissements cumulés")
	model.step()
	check.call(is_equal_approx(model.transport_factor(["centrale", "meridien"]), 0.6), "Expiration d'une cause conserve l'autre")
	model.step()
	check.call(is_equal_approx(model.transport_factor(["centrale", "meridien"]), 1.2), "Expiration sans facteur résiduel")
	content.events.events[0].target = "space"
	check.call(not World.Content.validate(content, data.regions, data.connections).is_empty(), "Type d'événement inconnu refusé")
	model.start("boreale", 2042, null, null, "degel2042")
	check.call(model.route_mode(["boreale", "orient"]) == "sea" and model.transport_factor(["boreale", "orient"]) == 0, "Route arctique maritime fermée avant saison")
	for i in range(12): model.step()
	check.call(is_equal_approx(model.transport_factor(["boreale", "orient"]), 0.8), "Coefficient maritime à l'ouverture saisonnière")
	for i in range(24): model.step()
	check.call(is_equal_approx(model.transport_factor(["boreale", "orient"]), 0.4) and model.transport_factor(["boreale", "centrale"]) == 0, "Congestion maritime et fermeture indépendantes en Dégel")
	model.start("boreale", 2042, null, null, "degel2042")
	for i in range(11): model.step()
	model.points = 100
	for id in ["polar", "seasonal", "transmission", "mobility"]: model.purchase(id)
	for region in model.regions:
		region.active = 10000 if region.id == "boreale" else 0
		region.removed = 0
		region.healthy = int(region.population) - region.active
	model.step()
	for region in model.regions:
		if region.id == "orient": check.call(region.active == 48, "Import maritime ×0,8, Mobilité ×3 et saison ×2 combinés")
	var store = Store.new()
	for scenario in ["standard", "degel2042"]:
		model.start("boreale", 42, null, null, scenario)
		for i in range(45 if scenario == "standard" else 36): model.step()
		var loaded = store.decode(JSON.parse_string(JSON.stringify(store.encode(model), "", true, true)))
		check.call(loaded.error.is_empty(), "Sauvegarde avec effets de transport : " + scenario)
		if not loaded.error.is_empty(): continue
		for i in range(40):
			model.step()
			loaded.world.step()
		check.call(model.regions == loaded.world.regions and model.cure == loaded.world.cure and model.rng.state == loaded.world.rng.state and model.active_events == loaded.world.active_events, "Reprise exacte et expiration transport : " + scenario)
	check.call(store.directory == "user://saves/transports-1", "Anciennes sauvegardes préservées dans un autre dossier")
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.start_game()
	check.call("Liaisons ouvertes" in scene.transport_details.text, "Types et compteurs régionaux affichés")
	scene.open_help()
	check.call("Boréale" in scene.Help.text_for(8, scene.world, 0) and "Maritime" in scene.Help.text_for(8, scene.world, 0), "Aide détaille les liaisons de la région")
	scene.queue_free()
	await tree.process_frame
