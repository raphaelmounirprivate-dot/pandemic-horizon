extends RefCounted
func run(tree: SceneTree, check: Callable) -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	var inputs = load("res://tests/input_journey.gd").new()
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		tree.root.size = dimensions
		scene.scenario_id = "degel2042"
		scene.decision_enabled = true
		scene.start_game()
		for i in range(28): scene.world.step()
		scene.show_game()
		await tree.process_frame
		await tree.process_frame
		var points = scene.world.points
		check.call(scene.EvolutionView.families(scene).reduce(func(n,g): return n+g.skills.size(),0) == 9,"Tous les nœuds sont répartis dans les onglets de famille")
		for id in scene.world.evolutions:
			scene.open_evolution(id)
			await tree.process_frame
			await tree.process_frame
			await inputs.click(tree,scene.evolution_buttons[id])
			await tree.process_frame
			check.call(scene.selected_evolution == id and scene.world.points == points and scene.world.purchased.is_empty(),"Sélection sans achat : "+id)
			check.call(scene.world.evolutions[id].effect in scene.evolution_detail.text,"Fiche donne l'effet complet avant achat : "+id)
			check.call(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(scene.evolution_purchase.get_global_rect()),"Achat explicite reste visible : "+id)
			check.call(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(scene.evolution_back.get_global_rect()),"Retour à la carte reste visible avec la fiche : "+id)
		scene.open_evolution("transmission")
		await tree.process_frame
		await tree.process_frame
		await inputs.click(tree,scene.evolution_buttons.transmission)
		await inputs.click(tree,scene.evolution_purchase)
		check.call(scene.world.points == points-12 and "transmission" in scene.world.purchased,"Dépense seulement après confirmation explicite")
		await inputs.click(tree,scene.evolution_buttons.transmission)
		check.call(scene.evolution_purchase.disabled and "Acquise" in scene.evolution_detail.text,"Évolution acquise consultable sans rachat")
		scene.close_evolution()
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
