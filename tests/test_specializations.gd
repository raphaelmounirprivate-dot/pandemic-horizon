extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const SPECS = [
	{"id":"land_network", "mode":"land", "start":"boreale", "target":"occident", "imports":54, "cure":1.08},
	{"id":"air_bridge", "mode":"air", "start":"centrale", "target":"meridien", "imports":108, "cure":1.18},
	{"id":"sea_logistics", "mode":"sea", "start":"boreale", "target":"centrale", "imports":60, "cure":1.12}]

func run(tree: SceneTree, check: Callable) -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH))
	var content = World.Content.load_files()
	for mutation in ["unknown", "self", "duplicate", "type", "asymmetric", "ancestor", "coefficient"]:
		var bad = content.duplicate(true)
		match mutation:
			"unknown": bad.evolutions.evolutions[3].excludes.append("absent")
			"self": bad.evolutions.evolutions[3].excludes.append("land_network")
			"duplicate": bad.evolutions.evolutions[3].excludes.append("air_bridge")
			"type": bad.evolutions.evolutions[3].excludes = "air_bridge"
			"asymmetric": bad.evolutions.evolutions[4].excludes.erase("land_network")
			"ancestor": bad.evolutions.evolutions[3].requires.append("air_bridge")
			"coefficient": bad.evolutions.evolutions[3].modifiers.land_multiplier = 0
		check.call(not World.Content.validate(bad, data.regions, data.connections).is_empty(), "Exclusion/modificateur invalide : " + mutation)
	for spec in SPECS:
		var model = World.new()
		model.start(spec.start)
		model.points = 100
		check.call(not model.purchase(spec.id).is_empty(), "Spécialisation exige Mobilité : " + spec.id)
		model.purchase("transmission")
		model.purchase("mobility")
		var before = model.points
		check.call(model.purchase(spec.id).is_empty() and model.points == before - int(model.evolutions[spec.id].cost), "Coût et achat unique : " + spec.id)
		check.call(model.specialization_id() == spec.id and not model.purchase(spec.id).is_empty(), "Choix conservé et achat double refusé")
		for other in SPECS:
			if other.id == spec.id: continue
			before = model.points
			check.call(model.purchase_reason(other.id).begins_with("Incompatible") and not model.purchase(other.id).is_empty() and model.points == before, "Exclusion dans les deux sens : " + spec.id + "/" + other.id)
		check.call(is_equal_approx(model.upgrade_modifier("cure_multiplier"), spec.cure), "Contrepartie de recherche exacte : " + spec.id)
		var base = World.new()
		base.start(spec.start)
		base.points = 100
		base.purchase("transmission")
		base.purchase("mobility")
		for current in [base, model]:
			for region in current.regions:
				if region.id == spec.start:
					region.active = 10000
					region.healthy = int(region.population) - 10000
			current.step()
		for region in model.regions:
			if region.id == spec.target: check.call(region.active == spec.imports, "Imports observables après spécialisation : " + spec.id)
		check.call(model.cure > base.cure, "Recherche réellement accélérée : " + spec.id)
		for edge in model.connections:
			if model.route_mode(edge) != spec.mode:
				check.call(model.transport_factor(edge) == base.transport_factor(edge), "Autre mode inchangé : " + spec.id)
		model.start(spec.start)
		for i in range(55):
			for id in ["transmission", "mobility", spec.id]:
				if id not in model.purchased:
					model.purchase(id)
					break
			model.step()
		var store = Store.new()
		var result = store.decode(JSON.parse_string(JSON.stringify(store.encode(model), "", true, true)))
		check.call(result.error.is_empty() and model.specialization_id() == spec.id, "Sauvegarde avec achat légal : " + spec.id)
		if result.error.is_empty():
			for i in range(20):
				model.step()
				result.world.step()
			check.call(model.regions == result.world.regions and model.cure == result.world.cure and model.rng.state == result.world.rng.state and model.purchased == result.world.purchased, "Reprise exacte du choix et de sa contrepartie")
	var store = Store.new()
	store.directory = "user://tests-choices"
	var forged = World.new()
	forged.start("boreale")
	for i in range(60): forged.step()
	forged.purchase("transmission")
	forged.purchase("mobility")
	var conflict = store.encode(forged)
	conflict.purchased.append_array(["land_network", "air_bridge"])
	conflict.points -= 19
	check.call(not store.decode(conflict).error.is_empty(), "Sauvegarde avec deux spécialisations refusée malgré un budget suffisant")
	var files = load("res://tests/test_persistence.gd").new()
	files.clean(store)
	for scenario in ["standard", "degel2042"]:
		var text = FileAccess.get_file_as_string("res://tests/fixtures/save-0.7-%s.json" % scenario)
		var payload = JSON.parse_string(text)
		for hash_value in Store.LEGACY_07_HASHES:
			payload.content = hash_value
			var migrated = store.decode(payload)
			check.call(migrated.error.is_empty() and migrated.has("warning"), "Empreinte 0.7 reconnue : " + scenario)
		var result = store.decode(JSON.parse_string(text))
		if not result.error.is_empty(): continue
		for i in range(20): result.world.step()
		var future_payload = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/future-0.7-%s.json" % scenario))
		var expected = store.decode(future_payload)
		check.call(expected.error.is_empty(), "État futur de référence 0.7 valide")
		if not expected.error.is_empty(): continue
		var future = store.encode(expected.world)
		var actual = store.encode(result.world)
		for key in ["content", "saved_at"]:
			future.erase(key)
			actual.erase(key)
		check.call(actual == future, "Vingt journées identiques à la vraie version 0.7 : " + scenario)
		DirAccess.make_dir_recursive_absolute(store.directory)
		store._write(store._path("slot1"), text)
		var loaded = store.load_slot("slot1")
		check.call(loaded.error.is_empty() and FileAccess.get_file_as_string(store._path("slot1")) == text, "Lecture 0.7 sans réécriture")
		check.call(store.save_slot("slot1", loaded.world).is_empty() and FileAccess.get_file_as_string(store._path("slot1") + ".bak") == text, "Premier enregistrement garde le fichier 0.7 en secours")
		payload.purchased.append("land_network")
		payload.points -= 9
		check.call(not store.decode(payload).error.is_empty(), "Fausse sauvegarde 0.7 avec nouvel achat rejetée")
	files.clean(store)
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.start_game()
	for i in range(45): scene.world.step()
	scene.world.purchase("transmission")
	scene.world.purchase("mobility")
	scene._refresh()
	await tree.process_frame
	await tree.process_frame
	scene.evolution_buttons.air_bridge.grab_focus()
	await tree.process_frame
	await tree.process_frame
	await tree.process_frame
	var group = scene.evolution_buttons.air_bridge.get_parent()
	check.call(group.get_parent().get_parent().get_global_rect().encloses(group.get_global_rect()), "Bouton, contrepartie et état visibles ensemble au clavier")
	await load("res://tests/input_journey.gd").new().key(tree, KEY_ENTER)
	await tree.process_frame
	check.call(group.get_parent().get_parent().get_global_rect().encloses(group.get_global_rect()), "Effet et état restent visibles après achat")
	check.call(scene.world.specialization_id() == "air_bridge" and "Pont aérien" in scene.specialization_details.text, "Choix au clavier dans le panneau défilant")
	check.call("Incompatible" in scene.evolution_reasons.land_network.text and "Incompatible" in scene.evolution_reasons.sea_logistics.text, "Motifs d'exclusion visibles après achat")
	check.call("×1,18" in scene.world.evolutions.air_bridge.effect, "Contrepartie annoncée avant achat")
	var inputs = load("res://tests/input_journey.gd").new()
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		tree.root.size = dimensions
		scene.scenario_id = "degel2042"
		scene.start_game()
		await tree.process_frame
		await tree.process_frame
		var ids = scene.world.evolutions.keys()
		scene.evolution_buttons[ids[0]].grab_focus()
		await tree.process_frame
		await tree.process_frame
		for id in ids:
			await tree.process_frame # Apply the deferred scroll after the layout frame.
			var button = scene.evolution_buttons[id]
			var row = button.get_parent()
			check.call(button.has_focus() and row.get_parent().get_parent().get_global_rect().encloses(row.get_global_rect()), "Tab : groupe complet visible à %d : %s" % [dimensions.x, id])
			await inputs.key(tree, KEY_TAB)
		for index in range(ids.size() - 1, -1, -1):
			await inputs.key(tree, KEY_TAB, true)
			var button = scene.evolution_buttons[ids[index]]
			var row = button.get_parent()
			check.call(button.has_focus() and row.get_parent().get_parent().get_global_rect().encloses(row.get_global_rect()), "Maj Tab : groupe complet visible à %d : %s" % [dimensions.x, ids[index]])
	# Holding a mouse press must not move the target before the release.
	tree.root.size = Vector2i(1280, 720)
	scene.scenario_id = "standard"
	scene.start_game()
	for i in range(45): scene.world.step()
	scene.world.purchase("transmission")
	scene.world.purchase("mobility")
	scene._refresh()
	for i in range(3): await tree.process_frame
	var target = scene.evolution_buttons.air_bridge
	var scroll = target.get_parent().get_parent().get_parent()
	scroll.scroll_vertical += roundi(target.get_global_rect().end.y - scroll.get_global_rect().end.y)
	for i in range(2): await tree.process_frame
	var original_rect = target.get_global_rect()
	var center = original_rect.get_center()
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.position = center
		event.global_position = center
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		tree.root.push_input(event, true)
		for i in range(4): await tree.process_frame
		if pressed: check.call(target.get_global_rect() == original_rect, "Le bouton reste immobile pendant un clic maintenu")
	check.call(scene.world.specialization_id() == "air_bridge", "Relâcher le clic maintenu achète la spécialisation")
	check.call(scroll.get_global_rect().encloses(target.get_parent().get_global_rect()), "Description révélée après relâchement du clic")
	scene.queue_free()
	await tree.process_frame
