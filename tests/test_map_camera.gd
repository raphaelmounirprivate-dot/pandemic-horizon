extends RefCounted
const Inputs = preload("res://tests/input_journey.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
func mouse(tree: SceneTree, point: Vector2, code: MouseButton, pressed: bool) -> void:
	var event = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = code
	event.pressed = pressed
	tree.root.push_input(event,true)
	await tree.process_frame
func run(tree: SceneTree, check: Callable) -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	var inputs = Inputs.new()
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		tree.root.size = dimensions
		scene.scenario_id = "degel2042"
		scene.decision_enabled = true
		scene.start_game()
		for i in range(28): scene.world.step()
		scene.show_game()
		await tree.process_frame
		await tree.process_frame
		var map = scene.map_view
		var before = Store.new().encode(scene.world)
		before.erase("saved_at")
		var controls = scene.pause_button.get_global_rect()
		var purchase = scene.evolution_buttons.mobility.get_global_rect()
		var choice = scene.decision_buttons.support.get_global_rect()
		var tools_clear = true
		for button in map.buttons: tools_clear = tools_clear and not button.get_rect().intersects(map.camera_tools.get_rect())
		check.call(tools_clear,"Aucune région masquée par les boutons de caméra en vue mondiale")
		var point: Vector2 = map.size*Vector2(.4,.6)
		await mouse(tree,map.global_position+point,MOUSE_BUTTON_WHEEL_UP,true)
		check.call(is_equal_approx(map.zoom,1.25),"Molette zoome la carte via le viewport")
		check.call((point-map.pan)/map.zoom == point,"Point visé conservé au zoom hors limite")
		var wheel_center: Vector2 = map.buttons[2].get_global_rect().get_center()
		await mouse(tree,wheel_center,MOUSE_BUTTON_WHEEL_UP,true)
		check.call(map.zoom > 1.25,"Molette fonctionne aussi au-dessus d'une région")
		var pan_before: Vector2 = map.pan
		var origin: Vector2 = map.global_position+map.size*.5
		await mouse(tree,origin,MOUSE_BUTTON_RIGHT,true)
		var motion = InputEventMouseMotion.new()
		motion.position = origin+Vector2(-30,-20)
		motion.relative = Vector2(-30,-20)
		motion.button_mask = MOUSE_BUTTON_MASK_RIGHT
		tree.root.push_input(motion,true)
		await tree.process_frame
		await mouse(tree,motion.position,MOUSE_BUTTON_RIGHT,false)
		check.call(map.pan != pan_before and not map.dragging,"Glisser droit déplace la carte et relâcher termine le geste")
		map.grab_focus()
		await inputs.key(tree,KEY_PLUS)
		check.call(map.zoom > 1.5625,"Clavier + zoome sur la carte focalisée")
		pan_before = map.pan
		await inputs.key(tree,KEY_RIGHT)
		check.call(map.pan.x < pan_before.x,"Flèche clavier déplace la caméra")
		map.zoom_at(map.size*.5,99)
		check.call(map.zoom == 4.0 and map.zoom_in.disabled,"Zoom maximal borné et indiqué")
		for i in range(map.buttons.size()):
			map.buttons[i].grab_focus()
			await tree.process_frame
			check.call(Rect2(Vector2.ZERO,map.size).encloses(map.buttons[i].get_rect()),"Focus révèle la région hors champ : " + str(i))
		map.buttons[2].grab_focus()
		await tree.process_frame
		await inputs.click(tree,map.buttons[2])
		check.call(scene.selected == 2 and scene.region_details.text.begins_with("Centrale"),"Clic après zoom sélectionne la bonne région")
		check.call(controls == scene.pause_button.get_global_rect() and purchase == scene.evolution_buttons.mobility.get_global_rect() and choice == scene.decision_buttons.support.get_global_rect(),"Caméra sans déplacement des commandes, achats ou choix")
		map.move_camera(Vector2(-99999,99999))
		check.call(map.pan.x == map.size.x*(1-map.zoom) and map.pan.y == 0,"Déplacement borné au monde")
		var state = map.camera_state()
		scene.open_help()
		scene.close_help()
		await tree.process_frame
		await tree.process_frame
		map = scene.map_view
		check.call(map.zoom == state.zoom and map.camera_state().center.is_equal_approx(state.center),"Retour d'aide conserve la caméra et la pause")
		check.call(scene.paused,"Exploration ne lance pas le temps")
		map.reset_view()
		map.zoom_at(map.size*.5,2)
		var center_before: Vector2 = map.camera_state().center
		tree.root.size = Vector2i(1600,900)
		await tree.process_frame
		await tree.process_frame
		check.call(map.camera_state().center.is_equal_approx(center_before),"Redimensionnement conserve le centre de la caméra")
		tree.root.size = dimensions
		await tree.process_frame
		await tree.process_frame
		var after = Store.new().encode(scene.world)
		after.erase("saved_at")
		check.call(before == after,"Caméra sans modification du modèle, RNG, points ou sauvegarde")
		map.grab_focus()
		await inputs.key(tree,KEY_HOME)
		check.call(map.zoom == 1.0 and map.pan == Vector2.ZERO and map.zoom_out.disabled,"Origine restaure la vue mondiale")
		map.zoom_at(map.size*.5,2)
		await inputs.click(tree,map.camera_tools.get_child(2))
		check.call(map.zoom == 1.0 and map.pan == Vector2.ZERO,"Bouton Vue mondiale restaure la carte")
		map.zoom_at(map.size*.5,4)
		scene.restart_game()
		await tree.process_frame
		check.call(scene.map_view.zoom == 1.0,"Nouvelle partie repart en vue mondiale")
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
