extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
func forbidden(node: Node) -> bool:
	if node is ScrollContainer or node is OptionButton or node is PopupMenu: return true
	for child in node.get_children():
		if forbidden(child): return true
	return false
func run(tree: SceneTree, check: Callable) -> void:
	var world = World.new()
	world.start("boreale")
	check.call(world.latest_flows.is_empty(),"Aucun déplacement inventé au départ")
	for i in range(20): world.step()
	check.call(not world.latest_flows.is_empty(),"Flux observés après croissance réelle")
	var legal = true
	for flow in world.latest_flows:
		legal = legal and flow.day == world.day and flow.units > 0 and flow.from != flow.to and world.route_is_open([flow.from,flow.to]) and flow.mode == world.route_mode([flow.from,flow.to])
	check.call(legal,"Flèches fondées sur les échanges orientés du jour, routes ouvertes")
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		tree.root.size = dimensions
		for scenario in ["standard","degel2042"]:
			scene.scenario_id = scenario
			scene.decision_enabled = scenario == "degel2042"
			scene.start_game()
			for i in range(28): scene.world.step()
			scene.show_game()
			await tree.process_frame
			await tree.process_frame
			var viewport = Rect2(Vector2.ZERO,Vector2(dimensions))
			check.call(not forbidden(scene.body),"Jeu sans liste déroulante ni panneau défilant : " + scenario)
			check.call(scene.evolution_buttons.size() == (9 if scenario == "degel2042" else 6),"Arbre d'évolutions complet intégré")
			for button in scene.evolution_buttons.values(): check.call(viewport.encloses(button.get_parent().get_global_rect()),"Achat, effet et prérequis visibles ensemble")
			check.call(viewport.encloses(scene.pause_button.get_global_rect()),"Commandes de jeu entièrement dans la fenêtre")
			if scenario == "degel2042":
				check.call(scene.decision_buttons.size() == 3 and scene.screen == "game","Trois choix intégrés, carte conservée")
				for button in scene.decision_buttons.values(): check.call(viewport.encloses(button.get_parent().get_global_rect()),"Conséquences de choix visibles sans ouvrir un écran")
				for i in range(3): scene.world.step()
				scene._refresh()
				check.call(scene.decision_buttons.is_empty(),"Échéance met à jour le panneau intégré")
	var model = scene.world
	var before = Store.new().encode(model)
	before.erase("saved_at")
	scene.map_view.motion_enabled = true
	var clock_before = scene.map_view.visual_time
	scene.map_view._process(.05)
	check.call(scene.map_view.visual_time > clock_before,"Animation avance hors de l'horloge de simulation")
	var after = Store.new().encode(model)
	after.erase("saved_at")
	check.call(before == after,"Animation sans changement de population, RNG, budget ou sauvegarde")
	scene.map_view.motion_enabled = false
	clock_before = scene.map_view.visual_time
	scene.map_view._process(.05)
	check.call(scene.map_view.visual_time == clock_before,"Pause fige les déplacements")
	var flow = model.latest_flows[0]
	model.active_events.append({"kind":"route_closure","target":[flow.from,flow.to]})
	check.call(scene.map_view.visible_flows().filter(func(item): return [item.from,item.to] == [flow.from,flow.to]).is_empty(),"Une fermeture retire la flèche concernée")
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
