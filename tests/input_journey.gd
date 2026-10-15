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
	check.call(scene.world.purchased.is_empty() and scene.status_label.text.begins_with("Prérequis"), "Clic achat refusé avec raison visible")
	await click(tree, scene.evolution_buttons.transmission)
	check.call("transmission" in scene.world.purchased and scene.evolution_buttons.transmission.disabled, "Clic achat applique et désactive")
	await click(tree, scene.evolution_buttons.mobility)
	check.call("mobility" in scene.world.purchased, "Achat prérequis débloqué à la souris")
	await key(tree, KEY_ESCAPE)
	check.call(scene.screen == "menu" and scene.paused, "Échap conserve la partie en pause")
	await key(tree, KEY_ENTER)
	check.call(scene.screen == "game" and scene.world.day == 0 and scene.world.purchased.is_empty(), "Entrée relance une nouvelle partie depuis le menu")
	var reachable: Array = []
	for i in range(30):
		await key(tree, KEY_TAB)
		var focused = scene.get_viewport().gui_get_focus_owner()
		if focused not in reachable:
			reachable.append(focused)
	var complete = true
	for button in scene.map_view.buttons:
		complete = complete and button in reachable
	for button in scene.evolution_buttons.values():
		complete = complete and button in reachable
	check.call(complete, "Tab atteint toutes les régions et évolutions, panneau défilant compris")
	scene.queue_free()
	await tree.process_frame
