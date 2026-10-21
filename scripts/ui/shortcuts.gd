extends RefCounted
## Keyboard shortcuts shared by every screen (Échap, E, F1–F4, Espace, 1/2/4).
const World = preload("res://scripts/simulation/world.gd")
const SPEEDS = {KEY_1: 1, KEY_2: 2, KEY_4: 4}

static func handle(ui, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		ui.mouse_press_active = event.pressed
	if is_instance_valid(ui.pending_dialog) and ui.pending_dialog.visible: return
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var viewport: Viewport = ui.get_viewport()
	if event.keycode == KEY_ESCAPE:
		escape(ui)
		viewport.set_input_as_handled()
	elif event.keycode == KEY_E and ui.screen in ["game","evolution"] and not (viewport.gui_get_focus_owner() is LineEdit):
		ui.open_evolution()
		viewport.set_input_as_handled()
	elif event.keycode == KEY_F1:
		ui.open_help()
		viewport.set_input_as_handled()
	elif event.keycode == KEY_F2 and ui.screen == "game" and (not ui.world.decision.is_empty() or World.Tactics.pending(ui.world) or World.Strategy.pending(ui.world)):
		ui.show_decision()
		viewport.set_input_as_handled()
	elif event.keycode == KEY_F3 and ui.screen in ["game","result","overview"]:
		ui.open_overview()
		viewport.set_input_as_handled()
	elif event.keycode == KEY_F4 and ui.screen == "game" and ui.world.crises_enabled:
		ui.map_view.focus_next_incident()
		viewport.set_input_as_handled()
	elif ui.screen == "game":
		if event.keycode == KEY_SPACE:
			ui.toggle_pause()
			viewport.set_input_as_handled()
		elif SPEEDS.has(event.keycode):
			ui.set_speed(SPEEDS[event.keycode])

static func escape(ui) -> void:
	match ui.screen:
		"help": ui.close_help()
		"evolution": ui.close_evolution()
		"setup": ui.setup_back()
		"overview": ui.close_overview()
		"saves": ui.close_saves()
		"decision": ui.show_game()
		_:
			if ui.tutorial != null: ui.finish_tutorial()
			else: ui.show_menu()
