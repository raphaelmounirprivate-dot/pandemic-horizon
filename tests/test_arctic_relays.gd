extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const Objectives = preload("res://scripts/gameplay/objectives.gd")
const Comparison = preload("res://scripts/analysis/strategy_comparison.gd")
const ID = "arctic_relays"

func model() -> RefCounted:
	var world = World.new()
	world.start("boreale",2042,null,null,"degel2042","normal",null,null,ID)
	return world

func buy(world: RefCounted) -> void:
	for id in ["transmission","mobility","discretion"]:
		if id not in world.purchased:
			world.purchase(id)
			break

func run(tree: SceneTree, check: Callable) -> void:
	var item = Objectives.definition(ID)
	var world = model()
	check.call(not item.is_empty() and world.objective.routes.size() == 2, "Objectif arctique et deux compteurs initialisés")
	for mutation in ["kind","quota","routes","duplicate","source","phase","early","deadline"]:
		var bad = Objectives.catalog()
		var record = bad.objectives[1]
		match mutation:
			"kind": record.kind = "absent"
			"quota": record.quota = 0
			"routes": record.routes = []
			"duplicate": record.routes[1].target = "orient"
			"source": record.source = "absent"
			"phase": record.phase = "absent"
			"early": record.routes[1].start_day = 36
			"deadline": record.deadline = 55
		var invalid = not Objectives.validate(bad).is_empty()
		if not invalid: invalid = not Objectives.validate_context(record,world.scenario,world.event_definitions).is_empty()
		check.call(invalid,"Contrat arctique invalide : " + mutation)
	for i in range(35): world.step()
	Objectives.record_exchange(world,"boreale","orient",9999)
	check.call(world.objective.routes.orient == 0 and world.objective.routes.centrale == 0,"Aucun échange compté avant sa fenêtre")
	world.step()
	check.call(world.day == 36 and world.objective.routes.orient > 0 and world.objective.routes.centrale == 0,"Orient démarre au J36, Centrale reste bloquée par inspection")
	var before = world.objective.duplicate(true)
	for edge in [["orient","boreale"],["boreale","occident"],["boreale","centrale"]]: Objectives.record_exchange(world,edge[0],edge[1],9999)
	Objectives.record_exchange(world,"boreale","orient",0)
	check.call(world.objective == before,"Direction inverse, autre route, fermeture cumulée et flux nul exclus")
	for i in range(3): world.step()
	check.call(world.day == 39 and world.objective.routes.centrale > 0,"Centrale démarre après la dernière fermeture au J39")
	world.day = 54
	world.objective.routes = {"orient":999,"centrale":999}
	Objectives.record_exchange(world,"boreale","orient",100)
	Objectives.record_exchange(world,"boreale","centrale",100)
	Objectives.update(world)
	check.call(world.objective.status == "completed" and world.objective.progress == 2 and world.objective.resolved_day == 54 and world.objective.routes.orient == 1000,"Quota plafonné et réussite au dernier jour inclus")
	before = world.objective.duplicate(true)
	var journal_size = world.journal.size()
	world.day = 55
	Objectives.record_exchange(world,"boreale","orient",100)
	Objectives.update(world)
	check.call(world.objective == before and world.journal.size() == journal_size,"Résolution et annonce figées")
	world = model()
	for i in range(55): world.step()
	check.call(world.objective.status == "failed" and world.objective.resolved_day == 54,"Attente sans achat échoue à l'échéance")
	var store = Store.new()
	for day in [0,35,36,38,39,45,54,55,90]:
		world = model()
		for i in range(day):
			buy(world)
			world.step()
		var decoded = store.decode(JSON.parse_string(JSON.stringify(store.encode(world),"",true,true)))
		check.call(decoded.error.is_empty(),"Sauvegarde arctique valide J" + str(day))
		if not decoded.error.is_empty(): continue
		check.call(decoded.world.objective == world.objective,"Compteurs entiers exacts après lecture")
		for i in range(20):
			for candidate in [world,decoded.world]:
				buy(candidate)
				candidate.step()
		var actual = store.encode(world)
		var expected = store.encode(decoded.world)
		actual.erase("saved_at")
		expected.erase("saved_at")
		check.call(actual == expected,"Vingt journées et résolution identiques après reprise")
	world = model()
	for i in range(40):
		buy(world)
		world.step()
	var valid = store.encode(world)
	for mutation in ["missing","negative","overflow","progress","future","early","legacy09"]:
		var bad = valid.duplicate(true)
		match mutation:
			"missing": bad.objective.routes.erase("orient")
			"negative": bad.objective.routes.orient = -1
			"overflow": bad.objective.routes.centrale = 1001
			"progress": bad.objective.progress = 2
			"future": bad.objective.resolved_day = 99
			"early": bad.objective.status = "completed"; bad.objective.routes = {"orient":1000,"centrale":1000}; bad.objective.progress = 2; bad.objective.resolved_day = 36
			"legacy09": bad.content = Store.LEGACY_09_HASH
		check.call(not store.decode(bad).error.is_empty(),"Sauvegarde arctique incohérente rejetée : " + mutation)
	store.directory = "user://tests-arctic-legacy"
	var files = load("res://tests/test_persistence.gd").new()
	files.clean(store)
	for name in ["standard-pending","standard-completed","standard-failed","degel2042"]:
		var text = FileAccess.get_file_as_string("res://tests/fixtures/save-0.9-%s.json" % name)
		var loaded = store.decode(JSON.parse_string(text))
		check.call(loaded.error.is_empty() and loaded.has("warning"),"Vraie sauvegarde 0.9 acceptée : " + name)
		if not loaded.error.is_empty(): continue
		for i in range(30):
			if name != "standard-failed": buy(loaded.world)
			loaded.world.step()
		var reference = store.decode(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/future-0.9-%s.json" % name)))
		var actual = store.encode(loaded.world)
		var expected = store.encode(reference.world)
		for key in ["history","purchase_history"]:
			actual.erase(key)
			expected.erase(key)
		actual.erase("saved_at")
		expected.erase("saved_at")
		check.call(actual == expected,"Trente vraies journées 0.9 conservées : " + name)
		DirAccess.make_dir_recursive_absolute(store.directory)
		store._write(store._path("slot1"),text)
		var resumed = store.load_slot("slot1")
		check.call(resumed.error.is_empty() and FileAccess.get_file_as_string(store._path("slot1")) == text,"Lecture 0.9 sans réécriture")
		check.call(store.save_slot("slot1",resumed.world).is_empty() and FileAccess.get_file_as_string(store._path("slot1") + ".bak") == text,"Premier enregistrement conserve l'original 0.9")
	files.clean(store)
	var success_count = 0
	var aggregate: Dictionary = {}
	for difficulty in ["easy","normal","hard"]:
		for seed_value in [7,42,2042]:
			for policy in Comparison.policies():
				var order = Comparison.policies()[policy]
				var active = Comparison.play("boreale",seed_value,"degel2042",difficulty,order,500,ID)
				var control = Comparison.play("boreale",seed_value,"degel2042",difficulty,order)
				check.call(active.error.is_empty() and control.error.is_empty() and active.state_hash == control.state_hash,"Relais sans dérive de simulation : " + difficulty + "/" + policy)
				if active.objective.status == "completed": success_count += 1
				if not aggregate.has(policy): aggregate[policy] = {"success":0,"min":500,"max":0}
				if active.objective.status == "completed":
					aggregate[policy].success += 1
					aggregate[policy].min = mini(aggregate[policy].min,active.objective.resolved_day)
					aggregate[policy].max = maxi(aggregate[policy].max,active.objective.resolved_day)
	print("ARCTIC_BALANCE: 99 paires ; %d réussites facultatives." % success_count)
	for policy in aggregate:
		var days = "aucune réussite" if aggregate[policy].success == 0 else "J%d–%d" % [aggregate[policy].min,aggregate[policy].max]
		print("ARCTIC_POLICY: %s %d/9 ; %s" % [policy,aggregate[policy].success,days])
	var inputs = load("res://tests/input_journey.gd").new()
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080)]:
		tree.root.size = dimensions
		scene.scenario_id = "degel2042"
		scene.show_new_game(2)
		await tree.process_frame
		await tree.process_frame
		check.call(not scene.objective_choice.disabled and not scene.objective_choice.button_pressed and "J39–54" in scene.menu_objective_detail.text,"Choix Dégel et fenêtres visibles, désactivé par défaut")
		scene.objective_choice.grab_focus()
		await inputs.key(tree,KEY_SPACE)
		check.call(scene.objective_id == ID,"Activation arctique au clavier")
		scene.start_game()
		for i in range(45):
			buy(scene.world)
			scene.world.step()
		scene._refresh()
		await tree.process_frame
		check.call("Orient" in scene.objective_details.text and "Centrale" in scene.objective_details.text,"Deux compteurs affichés")
		check.call(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(scene.pause_button.get_global_rect()),"Commandes visibles avec suivi arctique")
		scene.start_tutorial()
		check.call(scene.world.objective.is_empty(),"Tutoriel sans objectif arctique")
		scene.finish_tutorial()
		check.call(scene.world.objective.id == ID,"Retour du tutoriel conserve le suivi arctique")
		scene.restart_game()
		check.call(scene.world.day == 0 and scene.world.objective.routes.orient == 0,"Rejouer réinitialise les compteurs")
		scene.scenario_id = "standard"
		scene.show_new_game(2)
		check.call(scene.objective_id == "" and "Premiers relais" in scene.objective_choice.text,"Changement de scénario requiert une nouvelle activation")
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
