extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
func run(tree: SceneTree, check: Callable) -> void:
	var world = World.new()
	world.start("boreale")
	check.call(world.history.size() == 1 and world.history[0].day == 0,"Historique réel initial au jour zéro")
	for i in range(20):
		world.step()
		if world.day == 10: world.purchase("transmission")
	check.call(world.history.size() == 21 and world.purchase_history == [{"day":10,"id":"transmission","cost":12}],"Une mesure par jour et date réelle d'achat")
	var store = Store.new()
	var data = store.encode(world)
	var loaded = store.decode(JSON.parse_string(JSON.stringify(data)))
	check.call(loaded.error.is_empty(),"Historique accepté après JSON")
	if loaded.error.is_empty():
		for i in range(10):
			world.step()
			loaded.world.step()
		check.call(world.history == loaded.world.history and world.rng.state == loaded.world.rng.state,"Historique et RNG identiques après reprise")
	for mutation in ["population","day","future","cure","cost","purchase","size","type"]:
		var bad = data.duplicate(true)
		match mutation:
			"population": bad.history[0].active += 1
			"day": bad.history[1].day = 0
			"future": bad.history[-1].day = 100000
			"cure": bad.history[-1].cure = 10001
			"cost": bad.purchase_history[0].cost = 1
			"purchase": bad.purchase_history[0].id = "discretion"
			"size": bad.history.resize(2049)
			"type": bad.history = "invalid"
		check.call(not store.decode(bad).error.is_empty(),"Historique incohérent refusé : "+mutation)
	var legacy = data.duplicate(true)
	legacy.erase("history")
	legacy.erase("purchase_history")
	loaded = store.decode(legacy)
	check.call(loaded.error.is_empty() and loaded.world.history.is_empty() and loaded.world.purchase_history.is_empty(),"Ancien passé absent conservé absent")
	if loaded.error.is_empty():
		loaded.world.step()
		check.call(loaded.world.history.size() == 1 and loaded.world.history[0].day == 21,"Reprise historique au prochain jour sans passé inventé")
	var bounded = World.new()
	bounded.start("boreale")
	for i in range(2050):
		bounded.day = i
		World.History.record(bounded)
	check.call(bounded.history.size() == 2048 and bounded.history[0].day == 2,"Historique borné à 2048 journées")
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	var inputs = load("res://tests/input_journey.gd").new()
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		tree.root.size = dimensions
		scene.scenario_id = "degel2042"
		scene.objective_id = "arctic_relays"
		scene.decision_enabled = true
		scene.start_game()
		for i in range(28): scene.world.step()
		scene.show_game()
		await tree.process_frame
		var before = store.encode(scene.world)
		before.erase("saved_at")
		await inputs.key(tree,KEY_F3)
		await tree.process_frame
		check.call(scene.screen == "overview" and scene.paused,"F3 ouvre le bilan en pause")
		check.call(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(scene.history_chart.get_global_rect()),"Courbes dans la fenêtre")
		var back = scene.get_viewport().gui_get_focus_owner()
		check.call(back is Button and Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(back.get_global_rect()),"Retour visible et focalisé")
		await inputs.key(tree,KEY_F1)
		await inputs.key(tree,KEY_F1)
		check.call(scene.screen == "overview","Aide revient au bilan")
		await inputs.key(tree,KEY_ESCAPE)
		var after = store.encode(scene.world)
		after.erase("saved_at")
		check.call(scene.screen == "game" and scene.paused and before == after,"Retour conserve choix, historique et monde")
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
