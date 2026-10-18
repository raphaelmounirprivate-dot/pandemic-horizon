extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
func start(world, scenario="standard", seed_value=2042) -> String:
	return world.start("centrale" if scenario == "fragile2042" else "boreale",seed_value,null,null,scenario,"normal",null,null,"",false,true,null,true,null,true)
func stable(store,world) -> Dictionary:
	var result = store.encode(world)
	result.erase("saved_at")
	return result
func run(tree: SceneTree, check: Callable) -> void:
	var store = Store.new()
	check.call(World.Tactics.validate().is_empty(),"Profil réactif valide")
	for scenario in ["standard","degel2042","fragile2042"]:
		for seed_value in [7,42,2042,777,9001]:
			for choice in ["detour","endure","opportunity"]:
				var world = World.new()
				check.call(start(world,scenario,seed_value).is_empty(),"Initialisation profil réactif")
				for day in range(150):
					for id in ["transmission","mobility","discretion"]:
						if id not in world.purchased:
							world.purchase(id)
							break
					if World.Tactics.pending(world):
						var before = world.points
						var reason = World.Tactics.reason(world,choice)
						var result = World.Tactics.choose(world,choice)
						check.call(result == reason,"Réponse : éligibilité et achat concordants")
						check.call(world.points == before-(int(World.Tactics.option(choice).cost) if reason.is_empty() else 0),"Débit exact, refus sans mutation")
					world.step()
					# Sample boundaries across all 45 legal trajectories. Replaying the
					# original against the restored world verifies the future, rather
					# than comparing two identical restores to each other.
					var response_day = int(world.tactics.response.get("day",-100))
					if world.day % 10 != 0 and not World.Tactics.pending(world) and world.day not in [response_day,response_day+1,response_day+6,response_day+7] and world.outcome.is_empty(): continue
					var encoded = store.encode(world)
					check.call(encoded.format == 7,"Format 7 distinct")
					var loaded = store.decode(JSON.parse_string(JSON.stringify(encoded)))
					check.call(loaded.error.is_empty(),"Reprise réactive quotidienne %s/%d/%s/J%d" % [scenario,seed_value,choice,world.day])
					if not loaded.error.is_empty(): break
					check.call(stable(store,world) == stable(store,loaded.world),"Cibles et réponse conservées")
					loaded.world.step()
					world.step()
					check.call(stable(store,loaded.world) == stable(store,world),"Reprise identique à la partie originale avec effets")
					if not world.outcome.is_empty(): break
				for mutation in ["target","cost","goal","format"]:
					var corrupt = store.encode(world)
					match mutation:
						"target": corrupt.tactics.targets["unknown"] = "boreale"
						"cost": corrupt.points += 1
						"goal": corrupt.tactics.goal = {"status":"completed"}
						"format": corrupt.format = 6
					check.call(not store.decode(corrupt).error.is_empty(),"Rejet corruption réactive : "+mutation)
	# Isolate the timing and multiplicative semantics without faking a valid save.
	var world = World.new()
	start(world)
	world.day = 20
	world.tactics.response = {"status":"pending","event":"test","opened":20,"choice":"","day":-1,"reason":""}
	world.points = 2
	check.call(not World.Tactics.choose(world,"detour").is_empty() and world.points == 2,"Détour inaccessible sans 3 points")
	check.call(World.Tactics.choose(world,"opportunity").is_empty() and world.points == 1,"Occasion payante")
	check.call(World.Tactics.modifier(world,"transport_multiplier","air") == 1,"Pas d'effet rétroactif le jour du choix")
	world.active_events = [{"kind":"transport_multiplier","target":"air","factor":0.55,"source":"crisis"}]
	for day in range(21,27):
		world.day = day
		World.Tactics.update(world)
		check.call(is_equal_approx(world.event_modifier("transport_multiplier","air"),0.55*1.7),"Cumul panne et occasion pendant six jours")
		check.call(is_equal_approx(world.event_modifier("cure_multiplier"),1.18),"Contrepartie de recherche pendant six jours")
	world.day = 27
	World.Tactics.update(world)
	check.call(world.tactics.response.status == "expired" and is_equal_approx(world.event_modifier("transport_multiplier","air"),0.55),"Expiration exacte, panne restante conservée")
	start(world)
	world.tactics.response = {"status":"pending","event":"test","opened":0,"choice":"","day":-1,"reason":""}
	world.day = 2
	World.Tactics.update(world)
	check.call(World.Tactics.pending(world),"Trois journées incluses pour choisir")
	world.day = 3
	World.Tactics.update(world)
	check.call(world.tactics.response.choice == "endure" and world.tactics.response.reason == "timeout" and world.points == 8,"Absence de choix : subir gratuitement")
	start(world,"fragile2042")
	world.day = 59
	World.Tactics.record_exchange(world,"centrale","meridien",6000)
	World.Tactics.record_exchange(world,"centrale","savane",5999)
	World.Tactics.update_goal(world)
	check.call(world.tactics.goal.status == "pending","Deux relais nécessaires")
	world.day = 60
	World.Tactics.record_exchange(world,"centrale","savane",1)
	World.Tactics.update_goal(world)
	check.call(world.tactics.goal.status == "completed","J60 inclus pour réussir")
	start(world,"fragile2042")
	world.day = 60
	World.Tactics.update_goal(world)
	world.resolve_outcome()
	check.call(world.outcome == "defeat_network","Échéance obligatoire change réellement l'issue")
	# Native integration: menu, pause at opening, choice does not buy an evolution.
	var ui = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(ui)
	ui.set_process(false)
	ui.autosave_enabled = false
	ui.reactive_mode = true
	ui.start_game()
	check.call(ui.world.tactics_enabled,"Option du menu transmise au modèle")
	while not World.Tactics.pending(ui.world) and ui.world.outcome.is_empty(): ui.world.step()
	ui.show_game()
	await tree.process_frame
	check.call(ui.decision_buttons.has("endure") and ui.decision_buttons.size() == 3,"Trois réponses intégrées visibles")
	var purchases = ui.world.purchased.duplicate()
	ui.decision_buttons.endure.pressed.emit()
	await tree.process_frame
	check.call(ui.world.tactics.response.choice == "endure" and purchases == ui.world.purchased,"Réponse dédiée sans achat accidentel")
	ui.queue_free()
	await tree.process_frame
