extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Objectives = preload("res://scripts/gameplay/objectives.gd")
const Store = preload("res://scripts/persistence/save_store.gd")

func model() -> RefCounted:
	var world = World.new()
	world.start("boreale", 2042, null, null, "standard", "normal", null, null, "first_relays")
	return world

func hit(world: RefCounted, index: int, percent: int) -> void:
	var region = world.regions[index]
	region.active = int(region.population * percent / 100)
	region.removed = 0
	region.healthy = region.population - region.active

func run(tree: SceneTree, check: Callable) -> void:
	check.call(Objectives.validate(Objectives.catalog()).is_empty(), "Catalogue d'objectifs valide")
	for mutation in ["schema", "array", "item", "id", "duplicate", "name", "scenario", "regions", "fraction", "percent", "deadline"]:
		var bad = Objectives.catalog()
		match mutation:
			"schema": bad.schema_version = 99
			"array": bad.objectives = {}
			"item": bad.objectives[0] = null
			"id": bad.objectives[0].id = ""
			"duplicate": bad.objectives.append(bad.objectives[0].duplicate())
			"name": bad.objectives[0].name = ""
			"scenario": bad.objectives[0].scenario = "degel2042"
			"regions": bad.objectives[0].regions = 0
			"fraction": bad.objectives[0].regions = 1.5
			"percent": bad.objectives[0].coverage_percent = 101
			"deadline": bad.objectives[0].deadline = -1
		check.call(not Objectives.validate(bad).is_empty(), "Catalogue objectif rejeté : " + mutation)
	var world = model()
	var before = world.regions.duplicate(true)
	check.call(not world.start("boreale",2042,null,null,"degel2042","normal",null,null,"first_relays").is_empty() and world.regions == before, "Objectif Dégel refusé sans remplacer le monde")
	check.call(not world.start("boreale",2042,null,null,"standard","normal",null,null,"absent").is_empty(), "Objectif inconnu refusé")
	for i in range(3): hit(world, i, 9)
	Objectives.update(world)
	check.call(world.objective.progress == 0, "9 % ne satisfait pas le seuil 10 %")
	for i in range(2): hit(world, i, 10)
	world.day = 49
	Objectives.update(world)
	check.call(world.objective.progress == 2 and world.objective.status == "pending", "Deux régions au jour 49 restent en cours")
	hit(world, 2, 10)
	world.day = 50
	Objectives.update(world)
	check.call(world.objective.status == "completed" and world.objective.resolved_day == 50, "Réussite au jour limite incluse")
	var resolved = world.objective.duplicate(true)
	var journal_size = world.journal.size()
	world.day = 80
	Objectives.update(world)
	check.call(world.objective == resolved and world.journal.size() == journal_size, "Résultat figé et annonce unique après réussite")
	world = model()
	world.day = 50
	Objectives.update(world)
	check.call(world.objective.status == "failed" and world.objective.reason == "deadline", "Échéance sans couverture : non atteint")
	for i in range(3): hit(world, i, 20)
	world.day = 51
	Objectives.update(world)
	check.call(world.objective.status == "failed" and world.objective.progress == 0, "Progrès tardif ne transforme pas un échec")
	world = model()
	world.day = 30
	world.outcome = "defeat_cure"
	Objectives.update(world)
	check.call(world.objective.status == "failed" and world.objective.reason == "game_over" and world.objective.resolved_day == 30, "Fin prématurée résout l'objectif")
	world = model()
	for i in range(3): hit(world, i, 10)
	world.day = 30
	world.outcome = "defeat_cure"
	Objectives.update(world)
	check.call(world.objective.status == "completed", "Réussite facultative indépendante d'une défaite principale simultanée")
	var store = Store.new()
	for target_day in [0, 35, 59, 80, 200]:
		world = model()
		var plain = World.new()
		plain.start("boreale")
		for i in range(target_day):
			for candidate in [world, plain]:
				for id in ["transmission", "mobility", "discretion"]:
					if id not in candidate.purchased:
						candidate.purchase(id)
						break
			world.step()
			plain.step()
		check.call(world.regions == plain.regions and world.cure == plain.cure and world.points == plain.points and world.rng.state == plain.rng.state and world.score() == plain.score() and world.outcome == plain.outcome, "Objectif sans effet sur règles/RNG/score au jour " + str(target_day))
		var decoded = store.decode(JSON.parse_string(JSON.stringify(store.encode(world), "", true, true)))
		check.call(decoded.error.is_empty(), "Sauvegarde objectif valide au jour " + str(target_day))
		if not decoded.error.is_empty(): continue
		check.call(decoded.world.objective == world.objective, "État facultatif exact après chargement")
		for i in range(20):
			world.step()
			decoded.world.step()
		var actual = store.encode(world)
		var expected = store.encode(decoded.world)
		actual.erase("saved_at")
		expected.erase("saved_at")
		check.call(actual == expected, "Suite et annonce identiques après reprise")
	world = model()
	for i in range(60): world.step()
	var failed = store.decode(store.encode(world))
	check.call(failed.error.is_empty() and failed.world.objective.status == "failed" and failed.world.objective.resolved_day == 50, "Échec naturel sauvegardé et restauré")
	world = model()
	for i in range(35): world.step()
	var valid = store.encode(world)
	for mutation in ["missing", "type", "id", "status", "reason", "progress", "day", "success", "deadline", "extra", "old_format"]:
		var bad = valid.duplicate(true)
		match mutation:
			"missing": bad.erase("objective")
			"type": bad.objective = []
			"id": bad.objective.id = "absent"
			"status": bad.objective.status = "unknown"
			"reason": bad.objective.erase("reason"); bad.objective.other = ""
			"progress": bad.objective.progress = 3
			"day": bad.objective.resolved_day = 500
			"success": bad.objective.status = "completed"; bad.objective.resolved_day = 20
			"deadline": bad.objective.status = "failed"; bad.objective.reason = "deadline"; bad.objective.resolved_day = 35
			"extra": bad.objective.other = "extra"
			"old_format": bad.format = 1; bad.content = Store.LEGACY_08_HASH
		check.call(not store.decode(bad).error.is_empty(), "Sauvegarde objectif incohérente rejetée : " + mutation)
	# True 0.8 snapshots were made before this feature, from 259da07.
	store.directory = "user://tests-objectives"
	var files = load("res://tests/test_persistence.gd").new()
	files.clean(store)
	for scenario in ["standard", "degel2042"]:
		var text = FileAccess.get_file_as_string("res://tests/fixtures/save-0.8-%s.json" % scenario)
		var loaded = store.decode(JSON.parse_string(text))
		check.call(loaded.error.is_empty() and loaded.world.objective.is_empty() and loaded.has("warning"), "Partie 0.8 sans objectif rétroactif : " + scenario)
		if not loaded.error.is_empty(): continue
		for i in range(20): loaded.world.step()
		var reference = store.decode(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/future-0.8-%s.json" % scenario)))
		var actual = store.encode(loaded.world)
		var expected = store.encode(reference.world)
		actual.erase("saved_at")
		expected.erase("saved_at")
		check.call(actual == expected, "Reprise 0.8 identique aux vingt vrais jours futurs : " + scenario)
		DirAccess.make_dir_recursive_absolute(store.directory)
		store._write(store._path("slot1"), text)
		var resumed = store.load_slot("slot1")
		check.call(resumed.error.is_empty() and FileAccess.get_file_as_string(store._path("slot1")) == text, "Lecture 0.8 sans réécriture")
		check.call(store.save_slot("slot1", resumed.world).is_empty() and FileAccess.get_file_as_string(store._path("slot1") + ".bak") == text, "Premier enregistrement conserve la 0.8 en secours")
	files.clean(store)
	var inputs = load("res://tests/input_journey.gd").new()
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	for dimensions in [Vector2i(1280,720), Vector2i(1920,1080)]:
		tree.root.size = dimensions
		scene.show_menu()
		await tree.process_frame
		await tree.process_frame
		check.call(not scene.objective_choice.button_pressed and scene.objective_id == "", "Objectif décoché par défaut")
		scene.objective_choice.grab_focus()
		await inputs.key(tree, KEY_SPACE)
		check.call(scene.objective_id == "first_relays" and scene.objective_choice.button_pressed, "Activation de l'objectif par clavier")
		await inputs.click(tree, scene.objective_choice)
		check.call(scene.objective_id == "", "Désactivation de l'objectif par souris")
		await inputs.click(tree, scene.objective_choice)
		scene.start_game()
		await tree.process_frame
		await tree.process_frame
		check.call(scene.world.objective.id == "first_relays" and scene.objective_details.visible and scene.paused, "Nouvelle partie avec suivi visible et pause")
		check.call(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(scene.objective_details.get_global_rect()) and Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(scene.pause_button.get_global_rect()), "Objectif et commandes restent dans la fenêtre")
		for i in range(60):
			for id in ["transmission", "mobility", "discretion"]:
				if id not in scene.world.purchased:
					scene.world.purchase(id)
					break
			scene.world.step()
		scene._refresh()
		check.call("Réussi" in scene.objective_details.text, "Réussite réelle affichée dans le suivi")
		scene.start_tutorial()
		check.call(scene.world.objective.is_empty(), "Entraînement sans objectif de joueur")
		scene.finish_tutorial()
		check.call(scene.world.objective.status == "completed" and scene.objective_id == "first_relays", "Tutoriel restitue l'objectif et le choix")
		scene.restart_game()
		check.call(scene.world.objective.status == "pending" and scene.world.day == 0, "Rejouer conserve le choix et réinitialise le suivi")
		scene.scenario_id = "degel2042"
		scene.show_menu()
		check.call(not scene.objective_choice.disabled and not scene.objective_choice.button_pressed and scene.objective_id == "" and scene.objective_choice.text.contains("Relais arctiques"), "Dégel remplace le choix Standard et le décoche")
		scene.scenario_id = "standard"
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
