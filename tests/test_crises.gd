extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
func start(world, scenario="standard", seed_value=2042, source=null) -> String:
	return world.start("centrale" if scenario == "fragile2042" else "boreale",seed_value,null,null,scenario,"normal",null,null,"",false,true,null,true,source)
func stable(store,world) -> Dictionary:
	var result = store.encode(world)
	result.erase("saved_at")
	return result
func run(tree: SceneTree, check: Callable) -> void:
	var store = Store.new()
	var catalogs: Array = []
	for scenario in ["standard","degel2042","fragile2042"]:
		var world = World.new()
		check.call(start(world,scenario).is_empty(),"Aléas valides : "+scenario)
		check.call(world.crises_enabled and world.expanded_content and world.evolutions.size() == (24 if scenario == "degel2042" else 21),"Trois compétences de résilience intégrées")
		var events = world.event_definitions.filter(func(e): return e.get("source") == "crisis")
		check.call(events.size() == 12,"Douze tirages par partie")
		var kinds: Array = []
		for event in events.slice(0,8): kinds.append(event.template)
		check.call(kinds.size() == 8 and "storm" in kinds and "earthquake" in kinds and "communications" in kinds and "convoy" in kinds,"Huit types présents sans répétition dans le premier sac")
		for day in range(50):
			for id in ["transmission","mobility","backup_links","discretion","research_watch"]:
				if id not in world.purchased:
					world.purchase(id)
					break
			world.step()
		var encoded = store.encode(world)
		check.call(encoded.format == 6 and encoded.rules_profile == World.Crises.PROFILE,"Sauvegarde6 liée au profil crises")
		var restored = store.decode(JSON.parse_string(JSON.stringify(encoded)))
		check.call(restored.error.is_empty(),"Reprise JSON avec aléas actifs")
		if restored.error.is_empty():
			check.call(restored.world.event_definitions == world.event_definitions,"Calendrier reconstruit exactement")
			for day in range(75):
				world.step()
				restored.world.step()
			check.call(stable(store,world) == stable(store,restored.world),"Avenir identique après reprise avec RNG et historique")
		for mutation in ["profile","seed","event","format"]:
			var corrupt = encoded.duplicate(true)
			match mutation:
				"profile": corrupt.rules_profile = "unknown"
				"seed": corrupt.seed = "9001"
				"event": corrupt.activated.append("incident_99")
				"format": corrupt.format = 5
			check.call(not store.decode(corrupt).error.is_empty(),"Corruption refusée : "+mutation)
		catalogs.append(events)
	var world = World.new()
	start(world)
	var original = world.event_definitions.duplicate(true)
	var twin = World.new()
	start(twin,"standard",2042)
	check.call(twin.event_definitions == original and twin.rng.state == world.rng.state,"Même graine reproduit tirage sans consommer le hasard de propagation")
	start(twin,"standard",777)
	check.call(twin.event_definitions != original,"Autre graine change dates, cibles et types")
	var help = load("res://scripts/ui/help.gd")
	check.call("2042" in help.text_for(5,world,0) and "calendrier futur" in help.text_for(5,world,0),"Aide explique graine et tirage")
	check.call("Réserves régionales" in help.text_for(3,world,0) and "format 6" in help.text_for(6,world,0),"Compétences et sauvegarde expliquées")
	for skill in ["backup_links","research_watch","regional_reserves"]:
		check.call(world.purchase_reason(skill).begins_with("Prérequis"),"Prérequis explicite : "+skill)
	# Isolate modifier semantics with representative active hazards; do not serialize this fixture.
	for skill in ["backup_links","research_watch","regional_reserves"]: world.purchased.append(skill)
	for pair in [["transport_multiplier","air",0.55,0.775],["cure_multiplier","global",1.35,1.175],["growth_multiplier","boreale",0.65,0.825],["cure_multiplier","global",0.7,0.7],["transport_multiplier","sea",1.4,1.4]]:
		var effect = {"kind":pair[0],"target":pair[1],"factor":pair[2],"source":"crisis"}
		check.call(is_equal_approx(world.effect_factor(effect),pair[3]),"Atténuation et effets favorables préservés : "+pair[0])
		effect.erase("source")
		check.call(is_equal_approx(world.effect_factor(effect),pair[2]),"Ancien événement non atténué")
	start(world)
	var storm = world.event_definitions.filter(func(e): return e.get("template") == "storm")[0]
	world.day = storm.start_day-1
	world._update_events_and_detection()
	check.call(world.route_is_open(storm.target),"Route ouverte avant tempête")
	world.day = storm.start_day
	world._update_events_and_detection()
	check.call(not world.route_is_open(storm.target),"Tempête ferme une vraie route maritime")
	world.purchased.append("backup_links")
	check.call(not world.route_is_open(storm.target),"Liaisons de secours ne rouvrent pas une fermeture")
	var overlap = storm.duplicate(true)
	overlap.id = "overlap_test"
	overlap.duration = storm.duration+2
	world._add_event(overlap)
	world.day = storm.start_day+storm.duration
	world._update_events_and_detection()
	check.call(not world.route_is_open(storm.target),"Une seconde fermeture reste prioritaire après expiration")
	world.day += 2
	world._update_events_and_detection()
	check.call(world.route_is_open(storm.target),"Réouverture après dernière expiration")
	world.active_events = [{"kind":"transport_multiplier","target":"air","factor":0.55,"source":"crisis"},{"kind":"transport_multiplier","target":"air","factor":0.6}]
	check.call(is_equal_approx(world.event_modifier("transport_multiplier","air"),0.775*0.6),"Cumul multiplicatif après atténuation")
	var source = World.Crises.load_file()
	for mutation in ["duration","target","cycle","factor"]:
		var bad = source.duplicate(true)
		match mutation:
			"duration": bad.templates[0].min_duration = 0
			"target": bad.templates[0].target = "unknown"
			"cycle": bad.evolutions[0].requires = ["backup_links"]
			"factor": bad.evolutions[0].modifiers.incident_transport_penalty = 2
		var before = world.day
		check.call(not start(world,"standard",2042,bad).is_empty() and world.day == before,"Catalogue invalide sans mutation : "+mutation)
	for expanded in [false,true]:
		world.start("boreale",2042,null,null,"standard","normal",null,null,"",false,expanded)
		check.call(not world.crises_enabled and store.encode(world).format == (5 if expanded else 4),"Profils4/5 toujours inchangés sans option")
	await ui(tree,check)
func ui(tree,check):
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	var inputs = load("res://tests/input_journey.gd").new()
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		tree.root.size = resolution
		scene.crises_mode = false
		scene.scenario_id = "standard"
		scene.show_new_game(2)
		await tree.process_frame
		await tree.process_frame
		await inputs.click(tree,scene.crises_choice)
		check.call(scene.crises_mode and scene.advanced_mode and scene.advanced_choice.disabled,"Aléas activables et catalogue cohérent")
		for scenario in ["standard","degel2042","fragile2042"]:
			scene.scenario_id = scenario
			scene.objective_id = "arctic_relays" if scenario == "degel2042" else ""
			scene.decision_enabled = scenario == "degel2042"
			scene.show_new_game(2)
			await tree.process_frame
			await tree.process_frame
			check.call(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(scene.crises_choice.get_global_rect()),"Option dans la fenêtre : "+scenario)
			scene.start_game()
			check.call(scene.world.crises_enabled and scene.world.scenario.id == scenario,"Scénario aléas lancé : "+scenario)
			for day in range(28): scene.world.step()
			scene.show_game()
			await tree.process_frame
			await tree.process_frame
			for id in ["backup_links","research_watch","regional_reserves"]:
				scene.open_evolution(id)
				await tree.process_frame
				await tree.process_frame
				await inputs.click(tree,scene.evolution_buttons[id])
				await tree.process_frame
				check.call(scene.selected_evolution == id and scene.world.purchased.is_empty(),"Compétence consultable sans achat")
				check.call(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(scene.evolution_purchase.get_global_rect()) and Rect2(Vector2.ZERO,Vector2(resolution)).encloses(scene.evolution_buttons[id].get_global_rect()),"Compétence et achat intégrés")
				check.call(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(scene.evolution_back.get_global_rect()),"Retour à la carte visible avec 24 compétences")
			scene.close_evolution()
		scene.simulation_seed = 777
		scene.restart_game()
		check.call(scene.simulation_seed == 2042 and scene.world.crises_enabled,"Recommencer conserve graine et aléas")
	scene.show_new_game(2)
	await tree.process_frame
	var seed_input = scene.find_child("seed_input",true,false)
	seed_input.get_line_edit().grab_focus()
	seed_input.get_line_edit().text = "777"
	await inputs.key(tree,KEY_ENTER)
	check.call(scene.simulation_seed == 777,"Graine éditable au clavier")
	scene.start_game()
	check.call(scene.world.rng.seed == 777,"Graine choisie utilisée par la simulation")
	var directory_before = scene.save_store.directory
	scene.save_store.directory = "user://test-crises-ui"
	check.call(scene.save_store.save_slot("slot1",scene.world).is_empty(),"Partie aléas sauvegardée sur disque")
	scene.crises_mode = false
	scene.simulation_seed = 2042
	scene.load_saved("slot1")
	check.call(scene.crises_mode and scene.simulation_seed == 777 and scene.world.crises_enabled,"Chargement restaure options et graine du menu")
	for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
		var path = scene.save_store._path("slot1")+suffix
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	scene.save_store.directory = directory_before
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
