extends RefCounted
## Engine-delivered mouse/key events exercise hit-testing and focus traversal.
## These are synthetic input events, not physical Windows input.

func key(tree: SceneTree, code: Key, shift: bool = false) -> void:
	for pressed in [true, false]:
		var event = InputEventKey.new()
		event.keycode = code
		event.pressed = pressed
		event.shift_pressed = shift
		tree.root.push_input(event, true)
		await tree.process_frame

func click(tree: SceneTree, control: Control) -> void:
	var center = control.get_global_rect().get_center()
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.position = center
		event.global_position = center
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		tree.root.push_input(event, true)
		await tree.process_frame

func run(tree: SceneTree, check: Callable) -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	await tree.process_frame
	await tree.process_frame
	var launch = scene.get_viewport().gui_get_focus_owner()
	check.call(launch is Button and launch.text == "Nouvelle partie", "Focus initial sur Nouvelle partie")
	await click(tree, launch)
	await tree.process_frame
	check.call(scene.screen == "game" and scene.paused, "Clic réel dans le viewport lance la partie")
	if scene.screen != "game":
		scene.queue_free()
		await tree.process_frame
		return
	await click(tree, scene.map_view.buttons[2])
	check.call(scene.selected == 2 and scene.region_details.text.begins_with("Centrale"), "Clic carte sélectionne et affiche la région")
	await click(tree, scene.map_view.buttons[23])
	check.call(scene.selected == 23 and scene.region_details.text.begins_with("Mousson"), "Dernière des 24 régions sélectionnable à la souris")
	await click(tree, scene.pause_button)
	check.call(not scene.paused, "Clic pause reprend")
	await key(tree, KEY_SPACE)
	check.call(scene.paused, "Espace intercepte une seule fois le bouton focalisé")
	await key(tree, KEY_4)
	check.call(scene.speed == 4 and "×4" in scene.status_label.text, "Vitesse choisie visible en pause")
	await key(tree, KEY_TAB)
	var next = scene.get_viewport().gui_get_focus_owner()
	check.call(next is Button and next.text == "×1", "Tab suit l'ordre des commandes")
	await key(tree, KEY_TAB, true)
	check.call(scene.get_viewport().gui_get_focus_owner() == scene.pause_button, "Maj Tab revient à Pause")
	await key(tree, KEY_ENTER)
	check.call(not scene.paused, "Entrée active le bouton focalisé")
	await key(tree, KEY_SPACE)
	scene.world.points = 100
	scene._refresh()
	await click(tree, scene.evolution_buttons.mobility)
	check.call(scene.world.purchased.is_empty() and "Prérequis" in scene.evolution_detail.text, "Sélection sans achat avec prérequis visible")
	await click(tree, scene.evolution_buttons.transmission)
	check.call(scene.world.purchased.is_empty(),"Sélection de Diffusion ne dépense rien")
	await click(tree, scene.evolution_purchase)
	check.call("transmission" in scene.world.purchased and scene.evolution_purchase.disabled, "Achat explicite applique et désactive")
	await click(tree, scene.evolution_buttons.mobility)
	await click(tree, scene.evolution_purchase)
	check.call("mobility" in scene.world.purchased, "Achat prérequis débloqué à la souris")
	await key(tree, KEY_ESCAPE)
	check.call(scene.screen == "menu" and scene.paused, "Échap conserve la partie en pause")
	await key(tree, KEY_ENTER)
	check.call(scene.screen == "game" and scene.world.day == 0 and scene.world.purchased.is_empty(), "Entrée relance une nouvelle partie depuis le menu")
	var reachable: Array = []
	for i in range(scene.world.regions.size() + scene.world.evolutions.size() + 20):
		await key(tree, KEY_TAB)
		var focused = scene.get_viewport().gui_get_focus_owner()
		if focused not in reachable:
			reachable.append(focused)
	var complete = true
	for button in scene.map_view.buttons:
		complete = complete and button in reachable
	for button in scene.evolution_buttons.values():
		complete = complete and button in reachable
	for button in scene.map_view.camera_tools.get_children():
		if not button.disabled: complete = complete and button in reachable
	check.call(complete, "Tab atteint toutes les régions, évolutions et commandes de caméra actives")
	scene.show_menu()
	scene.scenario_choice.select(1)
	scene.scenario_choice.item_selected.emit(1)
	scene.difficulty_choice.select(2)
	scene.difficulty_choice.item_selected.emit(2)
	check.call(scene.start_choice.disabled and scene.start_id == "boreale", "Menu impose le départ de Dégel")
	check.call("1.30" in scene.menu_difficulty_detail.text and "Difficile" in scene.menu_difficulty_detail.text, "Menu explique la difficulté")
	await key(tree, KEY_ENTER)
	check.call(scene.world.scenario.id == "degel2042" and scene.world.difficulty.id == "hard" and scene.evolution_buttons.size() == 9, "Lancement applique scénario et difficulté")
	scene.show_menu()
	scene.scenario_choice.select(0)
	scene.scenario_choice.item_selected.emit(0)
	check.call(not scene.start_choice.disabled, "Standard rend le départ libre")
	scene.show_game()
	scene.restart_game()
	check.call(scene.world.scenario.id == "degel2042" and scene.world.difficulty.id == "hard", "Recommencer conserve les choix de la partie, pas les changements du menu")
	scene.queue_free()
	await tree.process_frame
