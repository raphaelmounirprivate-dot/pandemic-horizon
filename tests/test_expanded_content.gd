extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
func run(tree: SceneTree, check: Callable) -> void:
	var store = Store.new()
	var profile = World.Expanded.load_file()
	for scenario in ["standard","degel2042"]:
		var world = World.new()
		check.call(world.start("boreale",2042,null,null,scenario,"normal",null,null,"",false,true).is_empty(),"Profil enrichi valide : "+scenario)
		check.call(world.evolutions.size() == (18 if scenario == "standard" else 21),"Catalogue complet enrichi : "+scenario)
		check.call(world.event_definitions.size() >= 12,"Douze événements ou plus : "+scenario)
		for i in range(45):
			for id in ["transmission","mobility","relay","network"]:
				if id not in world.purchased:
					world.purchase(id)
					break
			world.step()
		var encoded = store.encode(world)
		check.call(encoded.format == 5 and encoded.rules_profile == World.Expanded.PROFILE,"Format5 attaché au profil enrichi")
		var loaded = store.decode(JSON.parse_string(JSON.stringify(encoded)))
		check.call(loaded.error.is_empty() and loaded.world.expanded_content,"Profil enrichi restauré")
		if loaded.error.is_empty():
			for i in range(50):
				world.step()
				loaded.world.step()
			var actual = store.encode(world)
			var expected = store.encode(loaded.world)
			actual.erase("saved_at")
			expected.erase("saved_at")
			check.call(actual == expected,"Cinquante journées enrichies exactes après reprise")
		for mutation in ["profile","hash","format","purchase"]:
			var bad = encoded.duplicate(true)
			match mutation:
				"profile": bad.rules_profile = "unknown"
				"hash": bad.content = "unknown"
				"format": bad.format = 4
				"purchase": bad.purchased.append("unknown")
			var refused = store.decode(bad)
			check.call(not refused.error.is_empty(),"Profil sauvegardé incohérent refusé : "+mutation)
			if mutation == "hash": check.call(refused.get("incompatible",false),"Empreinte future ne déclenche pas un secours silencieux")
	var classic = World.new()
	classic.start("boreale")
	check.call(store.encode(classic).format == 4 and not store.encode(classic).has("rules_profile"),"Nouvelles parties classiques gardent le format4")
	var classic_loaded = store.decode(store.encode(classic))
	check.call(classic_loaded.error.is_empty() and not classic_loaded.world.expanded_content and classic_loaded.world.evolutions.size() == 6,"Ancien profil classique sans ajout rétroactif")
	for mutation in ["count","cycle","modifier","event","agent","label"]:
		var bad = profile.duplicate(true)
		match mutation:
			"count": bad.evolutions.pop_back()
			"cycle": bad.evolutions[0].requires = ["retention"]
			"modifier": bad.evolutions[0].modifiers = {"unknown":1.0}
			"event": bad.events[0].target = "unknown"
			"agent": bad.agent.name = ""
			"label": bad.evolutions[0].short = "label-too-long"
		check.call(not classic.start("boreale",2042,null,null,"standard","normal",null,null,"",false,true,bad).is_empty(),"Catalogue enrichi invalide refusé : "+mutation)
		check.call(not classic.expanded_content and classic.evolutions.size() == 6,"Échec de validation sans mutation du monde courant")
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	var inputs = load("res://tests/input_journey.gd").new()
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		tree.root.size = dimensions
		scene.show_menu()
		await tree.process_frame
		await tree.process_frame
		if not scene.advanced_mode: await inputs.click(tree,scene.advanced_choice)
		check.call(scene.advanced_mode,"Profil enrichi activable au clic avant lancement")
		for scenario in ["standard","degel2042"]:
			scene.scenario_id = scenario
			scene.objective_id = "arctic_relays" if scenario == "degel2042" else ""
			scene.decision_enabled = scenario == "degel2042"
			scene.start_game()
			for i in range(28): scene.world.step()
			scene.show_game()
			await tree.process_frame
			await tree.process_frame
			var viewport = Rect2(Vector2.ZERO,Vector2(dimensions))
			check.call(scene.world.expanded_content and scene.evolution_buttons.size() == (21 if scenario == "degel2042" else 18),"Tous les achats enrichis intégrés : "+scenario)
			for id in scene.world.evolutions:
				await inputs.click(tree,scene.evolution_buttons[id])
				await tree.process_frame
				check.call(scene.selected_evolution == id and scene.world.purchased.is_empty(),"Sélection enrichie sans achat : "+id)
				check.call(viewport.encloses(scene.evolution_buttons[id].get_global_rect()) and viewport.encloses(scene.evolution_purchase.get_global_rect()) and viewport.encloses(scene.pause_button.get_global_rect()),"Nœud, achat et commandes enrichis visibles : "+id)
				check.call(scene.world.evolutions[id].effect in scene.evolution_detail.text,"Effet enrichi complet avant achat : "+id)
			if scenario == "degel2042":
				for button in scene.decision_buttons.values(): check.call(viewport.encloses(button.get_global_rect()),"Choix intégrés visibles avec21 évolutions")
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
