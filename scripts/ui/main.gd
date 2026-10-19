extends Control

const World = preload("res://scripts/simulation/world.gd")
const MapView = preload("res://scripts/ui/region_map.gd")
const SaveStore = preload("res://scripts/persistence/save_store.gd")
const Tutorial = preload("res://scripts/ui/tutorial.gd")
const Help = preload("res://scripts/ui/help.gd")
const Incidents = preload("res://scripts/ui/incident_view.gd")
const INK = Color("e1eee9")
const MUTED = Color("a7c4c9")
const ACCENT = Color("69d6bd")
const AMBER = Color("efbc70")
const CONFIG_PATH = "user://settings.cfg"

const Skills = preload("res://scripts/ui/skill_presenter.gd")
const MenuView = preload("res://scripts/ui/menu_view.gd")
const EvolutionView = preload("res://scripts/ui/evolution_view.gd")
var incident_button: Button
var map_legend: Label
var world = World.new()
var screen: String = "menu"
var paused: bool = true
var speed: int = 1
var elapsed: float = 0.0
var start_id: String = "boreale"
var scenario_id: String = "standard"
var difficulty_id: String = "normal"
var objective_id: String = ""
var objective_choice: CheckButton
var menu_objective_detail: Label
var objective_details: Label
var decision_enabled = false
var advanced_mode = false
var advanced_choice: CheckButton
var crises_mode = false
var reactive_mode = false
var reactive_choice: CheckButton
var crises_choice: CheckButton
var simulation_seed = 2042
var decision_choice: CheckButton
var decision_buttons: Dictionary = {}
var decision_notice: Label
var decision_area: VBoxContainer
var decision_signature = ""
var map_camera: Dictionary = {}
var reset_map_camera = false
var scenario_choice: OptionButton
var difficulty_choice: OptionButton
var start_choice: OptionButton
var menu_scenario_detail: Label
var menu_difficulty_detail: Label
var selected: int = 0
var body: VBoxContainer
var metrics: Label
var region_details: Label
var transport_details: Label
var specialization_details: Label
var journal_label: Label
var status_label: Label
var pause_button: Button
var map_view: Control
var evolution_buttons: Dictionary = {}
var evolution_reasons: Dictionary = {}
var selected_evolution = "transmission"
var evolution_detail: Label
var evolution_purchase: Button
var evolution_tree: Control
var evolution_family = "diffusion"
var evolution_tabs: Dictionary = {}
var evolution_title: Label
var evolution_subtitle: Label
var evolution_back: Button
var evolution_open_button: Button
var evolution_summary: Label
var evolution_return_paused = true
var effects_label: RichTextLabel
var save_store = SaveStore.new()
var autosave_enabled = true
var save_notice = ""
var saves_return = "menu"
var pending_dialog: ConfirmationDialog
var tutorial: RefCounted
var tutorial_session: Dictionary = {}
var tutorial_next: Button
var training_directory = "user://training"
var help_return = "menu"
var help_topic = 0
var help_text: RichTextLabel
var mouse_press_active = false
var overview_return = "game"
var history_chart: Control
var settings_path = CONFIG_PATH
var reduced_motion = false
var reading_large = false
var sounds_enabled = false
var sound_volume = 0.35
var feedback: Node

func _load_preferences() -> void:
	var config = ConfigFile.new()
	if config.load(settings_path) != OK: return
	reduced_motion = config.get_value("comfort","reduced_motion",false) == true
	reading_large = config.get_value("comfort","reading_large",false) == true
	sounds_enabled = config.get_value("audio","enabled",false) == true
	var level = config.get_value("audio","volume",0.35)
	sound_volume = clampf(float(level),0,1) if typeof(level) in [TYPE_FLOAT,TYPE_INT] and is_finite(float(level)) else 0.35
	if config.get_value("display","fullscreen",false) == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _save_preferences() -> void:
	var config = ConfigFile.new()
	config.load(settings_path)
	config.set_value("display","fullscreen",DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	config.set_value("comfort","reduced_motion",reduced_motion)
	config.set_value("comfort","reading_large",reading_large)
	config.set_value("audio","enabled",sounds_enabled)
	config.set_value("audio","volume",sound_volume)
	if is_instance_valid(feedback): feedback.configure(sounds_enabled,sound_volume)
	if config.save(settings_path) != OK and is_instance_valid(status_label):
		status_label.text = "Préférences appliquées ; enregistrement impossible sur ce PC."

func open_help() -> void:
	if screen == "help":
		close_help()
		return
	help_return = screen
	help_topic = 0
	show_help()

func show_help() -> void:
	screen = "help"
	paused = true
	elapsed = 0.0
	_reset_screen("Aide", "Consultez un sujet, puis revenez à votre partie en pause. F1 ou Échap pour fermer.")
	var topics = OptionButton.new()
	topics.custom_minimum_size.y = 44
	for title in Help.TITLES: topics.add_item(title)
	topics.select(help_topic)
	topics.item_selected.connect(func(index):
		help_topic = index
		help_text.text = Help.text_for(index, world, selected, tutorial.stage if tutorial != null else -1)
	)
	body.add_child(topics)
	help_text = RichTextLabel.new()
	help_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	help_text.focus_mode = Control.FOCUS_ALL
	help_text.add_theme_font_size_override("normal_font_size", 24 if reading_large else 20)
	help_text.text = Help.text_for(help_topic, world, selected, tutorial.stage if tutorial != null else -1)
	body.add_child(help_text)
	_button("Retour [F1]", close_help, body)
	topics.grab_focus()

func close_help() -> void:
	_return_to(help_return)

func _return_to(target: String) -> void:
	match target:
		"game": show_game()
		"evolution": show_evolution()
		"decision": show_decision()
		"result": show_result()
		"saves": show_saves()
		"settings": show_settings()
		"overview": show_overview()
		_: show_menu()

func start_tutorial() -> void:
	if tutorial != null: return
	tutorial_session = {"world": world, "selected": selected, "speed": speed, "save_store": save_store,
		"save_notice": save_notice, "saves_return": saves_return, "screen": screen,
		"start_id": start_id, "scenario_id": scenario_id, "difficulty_id": difficulty_id, "objective_id":objective_id,"decision_enabled":decision_enabled}
	world = World.new()
	var error = world.start_with({"start": "boreale"})
	if not error.is_empty():
		world = tutorial_session.world
		tutorial_session.clear()
		save_notice = error
		show_menu()
		return
	tutorial = Tutorial.new()
	save_store = SaveStore.new()
	save_store.directory = training_directory
	# Only the fixed training files are recycled; player slots are never touched.
	for slot in SaveStore.SLOTS:
		for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
			var path = save_store._path(slot) + suffix
			if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	selected = 0
	speed = 1
	paused = true
	elapsed = 0.0
	save_notice = "Entraînement séparé · vos parties et sauvegardes sont conservées."
	show_game()

func _restore_tutorial_session() -> String:
	var target: String = tutorial_session.screen
	world = tutorial_session.world
	selected = tutorial_session.selected
	speed = tutorial_session.speed
	save_store = tutorial_session.save_store
	save_notice = tutorial_session.save_notice
	saves_return = tutorial_session.saves_return
	start_id = tutorial_session.start_id
	scenario_id = tutorial_session.scenario_id
	difficulty_id = tutorial_session.difficulty_id
	objective_id = tutorial_session.objective_id
	decision_enabled = tutorial_session.decision_enabled
	tutorial = null
	tutorial_session.clear()
	paused = true
	elapsed = 0.0
	screen = target
	return target

func finish_tutorial() -> void:
	if tutorial == null: return
	_return_to(_restore_tutorial_session())

func next_lesson() -> void:
	if tutorial == null or not tutorial.ready: return
	if tutorial.stage == 5:
		finish_tutorial()
		return
	tutorial.next(world)
	paused = true
	elapsed = 0.0
	show_game()

func select_region(index: int) -> void:
	selected = index
	if is_instance_valid(map_view): map_view.selected = index
	if tutorial != null: tutorial.select_region(index, world)
	_refresh()

func autosave() -> String:
	if tutorial != null or not autosave_enabled or world.regions.is_empty(): return ""
	var error = save_store.save_slot("auto", world, selected, speed)
	save_notice = "Sauvegarde automatique : " + ("jour %d." % world.day if error.is_empty() else error)
	return error

func request_quit() -> void:
	if is_instance_valid(pending_dialog) and pending_dialog.visible: return
	if tutorial != null: _return_to(_restore_tutorial_session())
	if autosave().is_empty():
		get_tree().quit()
	else:
		confirm_action("La sauvegarde a échoué. " + save_notice + "\nQuitter sans sauvegarder ?", func(): get_tree().quit())

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: request_quit()

func confirm_action(message: String, action: Callable) -> void:
	if screen == "game":
		paused = true
		elapsed = 0.0
		_refresh()
	var dialog = ConfirmationDialog.new()
	pending_dialog = dialog
	dialog.title = "Confirmer l'action"
	dialog.dialog_text = message
	dialog.ok_button_text = "Confirmer"
	dialog.cancel_button_text = "Annuler"
	add_child(dialog)
	dialog.confirmed.connect(func():
		dialog.queue_free()
		action.call()
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(620, 180))
	dialog.get_cancel_button().grab_focus()

func open_saves() -> void:
	saves_return = screen
	show_saves()

func close_saves() -> void:
	if saves_return == "game": show_game()
	elif saves_return == "result": show_result()
	else: show_menu()

func save_manual(slot: String) -> void:
	var error = save_store.save_slot(slot, world, selected, speed)
	if error.is_empty() and tutorial != null and tutorial.stage == 5: tutorial.saved_slot = slot
	save_notice = "Partie enregistrée dans l'emplacement %s." % slot.trim_prefix("slot") if error.is_empty() else error
	show_saves()

func load_saved(slot: String) -> void:
	var result = save_store.load_slot(slot)
	if not result.error.is_empty():
		save_notice = result.error + " La partie en mémoire est conservée."
		show_saves()
		return
	world = result.world
	reset_map_camera = true
	if tutorial != null and tutorial.stage == 5 and tutorial.saved_slot == slot: tutorial.ready = true
	selected = result.selected
	speed = result.speed
	start_id = world.start_region_id
	scenario_id = world.scenario.id
	difficulty_id = world.difficulty.id
	if tutorial == null: objective_id = world.objective.get("id", "")
	if tutorial == null: decision_enabled = not world.decision.is_empty()
	if tutorial == null: advanced_mode = world.expanded_content
	if tutorial == null:
		crises_mode = world.crises_enabled
		reactive_mode = world.tactics_enabled
		simulation_seed = world.rng.seed
	paused = true
	elapsed = 0.0
	save_notice = result.get("warning", "Partie chargée en pause.")
	if world.outcome.is_empty(): show_game()
	else: show_result()

func show_saves() -> void:
	preload("res://scripts/ui/saves_view.gd").build(self)

func _ready() -> void:
	autosave_enabled = not ("--no-autosave" in OS.get_cmdline_user_args() or "--smoke-test" in OS.get_cmdline_user_args())
	get_tree().auto_accept_quit = false
	_apply_theme()
	_load_preferences()
	feedback = preload("res://scripts/ui/audio_feedback.gd").new()
	add_child(feedback)
	feedback.configure(sounds_enabled,sound_volume)
	show_menu()
	if "--smoke-test" in OS.get_cmdline_user_args():
		call_deferred("_smoke_test")

func _smoke_test() -> void:
	# Exercise the actual exported resources; no dependency on the tests folder.
	if not preload("res://scripts/ui/runtime_smoke.gd").run(self):
		get_tree().quit(1)
		return
	print("RUNTIME_SMOKE_OK: classic scenarios and replay, tutorial, help, objectives and decisions, enriched profile5, comfort and audio, crises profile6, reactive profile7 targets/response/goal, active incident map and scopes, restart, settings, menu")
	get_tree().quit()

func _apply_theme() -> void:
	var design = Theme.new()
	design.default_font_size = 18
	design.set_color("font_color", "Label", INK)
	design.set_color("font_color", "Button", INK)
	design.set_color("font_disabled_color", "Button", MUTED)
	design.set_constant("separation", "VBoxContainer", 8)
	design.set_constant("separation", "HBoxContainer", 16)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("254954") if state in ["hover", "pressed"] else Color("16333e")
		style.set_corner_radius_all(6)
		style.content_margin_left = 16
		style.content_margin_right = 16
		style.content_margin_top = 10
		style.content_margin_bottom = 10
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.border_color = ACCENT
			style.set_border_width_all(2)
		design.set_stylebox(state, "Button", style)
	theme = design

func _reset_screen(title: String, subtitle: String) -> void:
	if is_instance_valid(map_view):
		map_camera = map_view.camera_state() if not reset_map_camera and map_view.world == world else {}
		map_view = null
	if reset_map_camera: map_camera = {}
	for child in get_children():
		if child == feedback: continue
		remove_child(child)
		child.queue_free()
	evolution_buttons.clear()
	evolution_reasons.clear()
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16 if screen == "game" else 24)
	add_child(margin)
	body = VBoxContainer.new()
	if screen == "game": body.add_theme_constant_override("separation",4)
	margin.add_child(body)
	var heading = HBoxContainer.new()
	body.add_child(heading)
	var title_label = _label(title, 30)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title_label)
	heading.add_child(_label("PROTOTYPE 0.23", 16, MUTED))
	body.add_child(_label(subtitle, 16, MUTED))

func _label(text: String, font_size: int = 18, color: Color = INK) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(text: String, action: Callable, parent: Node) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size.y = 44
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func show_menu() -> void:
	MenuView.build(self)

func _menu_catalog() -> Dictionary:
	return MenuView.catalog(self)

func _update_menu_choices(catalog: Dictionary) -> void:
	MenuView.update_choices(self,catalog)

func show_settings() -> void:
	load("res://scripts/ui/settings_view.gd").build(self)

func start_game() -> void:
	reset_map_camera = true
	var error = world.start_with({"start": start_id, "seed": simulation_seed, "scenario": scenario_id, "difficulty": difficulty_id, "objective": objective_id, "decision": decision_enabled, "expanded": advanced_mode, "crises": crises_mode, "reactive": reactive_mode})
	if not error.is_empty():
		show_menu()
		body.add_child(_label("Impossible de démarrer : " + error))
		return
	selected = 0
	for i in range(world.regions.size()):
		if world.regions[i].id == start_id:
			selected = i
	speed = 1
	paused = true
	elapsed = 0.0
	show_game()

func restart_game() -> void:
	scenario_id = world.scenario.id
	difficulty_id = world.difficulty.id
	start_id = world.start_region_id
	objective_id = world.objective.get("id", "")
	decision_enabled = not world.decision.is_empty()
	advanced_mode = world.expanded_content
	crises_mode = world.crises_enabled
	reactive_mode = world.tactics_enabled
	simulation_seed = world.rng.seed
	start_game()

func show_game() -> void:
	screen = "game"
	_reset_screen("Tutoriel guidé" if tutorial != null else "Pandemic Horizon", "Entraînement séparé · Six exercices" if tutorial != null else "%s · %s · Objectif : 90 %% avant le remède" % [world.scenario.name,world.difficulty.name])
	body.get_child(0).get_child(0).add_theme_font_size_override("font_size",22)
	metrics = _label("",20,ACCENT)
	body.add_child(metrics)
	objective_details = _label("",13,MUTED)
	objective_details.visible = not world.objective.is_empty() or (world.tactics_enabled and not world.tactics.goal.is_empty())
	body.add_child(objective_details)
	var content = HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(content)
	var map_column = VBoxContainer.new()
	map_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(map_column)
	map_view = MapView.new()
	map_view.setup(world)
	map_view.selected = selected
	map_view.region_selected.connect(select_region)
	map_column.add_child(map_view)
	map_view.restore_camera(map_camera)
	reset_map_camera = false
	map_legend = _label("",13,MUTED)
	map_legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_column.add_child(map_legend)
	decision_area = VBoxContainer.new()
	decision_signature = ""
	map_column.add_child(decision_area)
	build_inline_decision(decision_area)
	effects_label = RichTextLabel.new()
	effects_label.custom_minimum_size.y = 48
	effects_label.visible = not World.Decisions.pending(world) and not World.Tactics.pending(world)
	effects_label.add_theme_font_size_override("normal_font_size",13)
	effects_label.add_theme_color_override("default_color",AMBER)
	map_column.add_child(effects_label)
	var sidebar = VBoxContainer.new()
	sidebar.custom_minimum_size.x = 380
	sidebar.add_theme_constant_override("separation",2)
	content.add_child(sidebar)
	region_details = _label("",14)
	sidebar.add_child(region_details)
	transport_details = _label("",13,MUTED)
	sidebar.add_child(transport_details)
	evolution_open_button = _button("", open_evolution, sidebar)
	evolution_open_button.custom_minimum_size.y = 64
	evolution_open_button.add_theme_font_size_override("font_size",22)
	evolution_summary = _label("",14,MUTED)
	evolution_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar.add_child(evolution_summary)
	status_label = _label("",14,MUTED)
	body.add_child(status_label)
	journal_label = _label("",14,MUTED)
	journal_label.custom_minimum_size.y = 22 if tutorial == null else 44
	if tutorial == null:
		journal_label.mouse_filter = Control.MOUSE_FILTER_STOP
		journal_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		journal_label.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: open_overview())
	body.add_child(journal_label)
	var controls = HBoxContainer.new()
	body.add_child(controls)
	pause_button = _button("", toggle_pause, controls)
	var initial_focus: Button = pause_button
	for value in [1, 2, 4]:
		_button("×%d" % value, func():
			speed = value
			_refresh()
		, controls)
	if tutorial == null:
		_button("Recommencer", restart_game, controls)
		_button("Menu", show_menu, controls)
		_button("Sauvegardes", open_saves, controls)
		_button("Monde [F3]",open_overview,controls)
		incident_button = _button("Local [F4]",func(): map_view.focus_next_incident(),controls) if world.crises_enabled else null
	else:
		if tutorial.stage == 5: initial_focus = _button("Sauvegardes d'essai", open_saves, controls)
		tutorial_next = _button("Terminer" if tutorial.stage == 5 else "Continuer", next_lesson, controls)
		_button("Quitter l'entraînement", finish_tutorial, controls)
		if tutorial.stage == 1: initial_focus = map_view.buttons[2]
		elif tutorial.stage == 2: initial_focus = evolution_open_button
		elif tutorial.stage == 3: initial_focus = map_view.buttons[0]
		if tutorial.ready: initial_focus = tutorial_next
	_button("Aide [F1]", open_help, controls)
	_refresh()
	initial_focus.grab_focus()

func buy_evolution(id: String) -> void:
	if tutorial != null and (tutorial.stage != 2 or id != "transmission"): return
	var error = world.purchase(id)
	if error.is_empty(): feedback.play_cue("purchase")
	if tutorial != null and error.is_empty(): tutorial.ready = true
	if screen == "evolution":
		EvolutionView.refresh(self)
		status_label.text = error if not error.is_empty() else "%s acquise. Points restants : %d." % [world.evolutions[id].name, world.points]
		if error.is_empty() and tutorial != null: evolution_back.grab_focus()
		return
	_refresh()
	if not error.is_empty(): status_label.text = error

func select_evolution(id: String) -> void:
	if not world.evolutions.has(id): return
	selected_evolution = id
	if screen != "evolution": return
	if EvolutionView.family_of(self,id) != evolution_family:
		show_evolution_family(EvolutionView.family_of(self,id))
		return
	if tutorial == null: status_label.text = ""
	EvolutionView.refresh(self)

## Purchase reason including the tutorial restriction (only Diffusion in exercise 3).
func purchase_reason_for(id: String) -> String:
	var reason = world.purchase_reason(id)
	if tutorial != null and id not in world.purchased and (tutorial.stage != 2 or id != "transmission"):
		return "Hors exercice" + (" · " + reason if not reason.is_empty() else "")
	return reason

## Opens the Évolution screen, optionally on the tab of a given skill. The game pauses
## and returns to its previous pause state when the screen is closed.
func open_evolution(id: String = "") -> void:
	if world.regions.is_empty() or not world.outcome.is_empty(): return
	if screen == "evolution":
		if id.is_empty(): close_evolution()
		else: select_evolution(id)
		return
	if screen != "game": return
	evolution_return_paused = paused
	if not id.is_empty() and world.evolutions.has(id):
		selected_evolution = id
		evolution_family = EvolutionView.family_of(self,id)
	show_evolution()
	if evolution_buttons.has(selected_evolution): evolution_buttons[selected_evolution].grab_focus()

func show_evolution() -> void:
	EvolutionView.build(self)

func show_evolution_family(family_id: String) -> void:
	evolution_family = family_id
	if EvolutionView.family_of(self,selected_evolution) != family_id: selected_evolution = ""
	show_evolution()
	if evolution_buttons.has(selected_evolution): evolution_buttons[selected_evolution].grab_focus()

func close_evolution() -> void:
	if screen != "evolution": return
	show_game()
	paused = evolution_return_paused if tutorial == null else true
	_refresh()
	# In the tutorial, show_game() already focused Continuer once the exercise succeeded.
	if tutorial == null or not tutorial.ready: evolution_open_button.grab_focus()

func build_inline_decision(parent: Control) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	decision_signature = JSON.stringify(world.decision)+JSON.stringify(world.tactics)+str(world.points)
	decision_buttons.clear()
	decision_notice = null
	if World.Tactics.pending(world) or (world.tactics_enabled and not world.tactics.response.is_empty() and not World.Decisions.pending(world)):
		load("res://scripts/ui/crisis_response_view.gd").build(self,parent)
		return
	if world.decision.is_empty(): return
	decision_notice = _label("",13,AMBER)
	decision_notice.visible = false
	var title = World.Decisions.summary(world)
	if world.decision_profile == "0.11": title += " · Tarif historique 6 pts"
	parent.add_child(_label(title,13,AMBER))
	if World.Decisions.pending(world):
		var choices = HBoxContainer.new()
		choices.add_theme_constant_override("separation",8)
		parent.add_child(choices)
		for choice in World.Decisions.definition(world).choices:
			var id = choice.id
			var column = VBoxContainer.new()
			column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			choices.add_child(column)
			var button = _button("%s · %d pts" % [choice.name,choice.cost],func():
				var error = World.Decisions.choose(world,id)
				if error.is_empty():
					feedback.play_cue("purchase")
					autosave()
					show_game()
				else:
					decision_notice.text = error
					decision_notice.show()
			,column)
			button.add_theme_font_size_override("font_size",13)
			decision_buttons[id] = button
			var detail = _label(("Sans ajout d'effet" if id == "observe" else "Mer ×%.2f · remède ×%.2f\n12 jours dès demain" % [choice.sea,choice.cure])+"\n"+World.Decisions.reason(world,id),13,MUTED)
			detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			column.add_child(detail)
		parent.add_child(_label("Choix irréversible · Sans choix : maintien gratuit au J31 · Les fermetures restent prioritaires",12,AMBER))
	parent.add_child(decision_notice)

func show_decision() -> void:
	if tutorial != null or (world.decision.is_empty() and not World.Tactics.pending(world)): return
	paused = true
	elapsed = 0.0
	show_game()
func toggle_pause() -> void:
	if tutorial != null and not tutorial.can_run(): return
	paused = not paused
	elapsed = 0.0
	_refresh()

func _refresh() -> void:
	if screen != "game":
		return
	if decision_signature != JSON.stringify(world.decision)+JSON.stringify(world.tactics)+str(world.points): build_inline_decision(decision_area)
	effects_label.visible = not World.Decisions.pending(world) and not World.Tactics.pending(world)
	metrics.text = "Jour %d     Touchés : %.1f %%     Remède : %.1f %%     Points : %d     Détectées : %d/%d" % [world.day, world.coverage() * 100, world.cure, world.points, world.detected_count(), world.regions.size()]
	objective_details.text = World.Tactics.goal_summary(world) if world.tactics_enabled and not world.tactics.goal.is_empty() else World.Objectives.summary(world)
	var region = world.regions[selected]
	region_details.text = "%s · Population : %d\nSains : %d · Actifs : %d · Retirés : %d\n%s" % [region.name, region.population, region.healthy, region.active, region.removed, "Détectée" if region.detected else "Non détectée"]
	if world.scenario.id != "standard":
		region_details.text += " · Climat local ×%.2f" % world.climate_factor(region.id)
	transport_details.text = world.transport_summary(region.id)
	var available = world.evolutions.keys().filter(func(id): return purchase_reason_for(id).is_empty())
	evolution_open_button.text = "Évolution [E] · %d pts" % world.points
	var owned: Array[String] = []
	for group in EvolutionView.families(self):
		owned.append("%s %d/%d" % [group.name, group.skills.filter(func(id): return id in world.purchased).size(), group.skills.size()])
	var specialization = world.specialization_id()
	evolution_summary.text = "%s\n%s%s" % [" · ".join(owned), ("Aucune compétence achetable" if available.is_empty() else "%d achetable%s maintenant" % [available.size(), "s" if available.size() > 1 else ""]), "" if specialization.is_empty() else " · Spécialisation : " + world.evolutions[specialization].name]
	pause_button.text = "Reprendre [Espace]" if paused else "Pause [Espace]"
	status_label.text = ("En pause" if paused else "Simulation en cours") + " · Vitesse ×%d" % speed
	if not save_notice.is_empty(): status_label.text += " · " + save_notice
	status_label.clip_text = true
	journal_label.text = "Actu · " + world.journal[-1] if not world.journal.is_empty() else ""
	journal_label.tooltip_text = "Actualités [F3]\n" + "\n".join(world.journal.slice(maxi(0,world.journal.size()-5)))
	journal_label.clip_text = true
	if tutorial != null:
		status_label.text = "Étape %d / 6 · %s · %s" % [tutorial.stage + 1, Tutorial.TITLES[tutorial.stage], "Action réussie : continuez." if tutorial.ready else "À vous de jouer"]
		journal_label.text = tutorial.instruction(world.day)
		journal_label.clip_text = false
		journal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var just_completed = tutorial.ready and tutorial_next.disabled
		tutorial_next.disabled = not tutorial.ready
		if just_completed: tutorial_next.grab_focus()
		pause_button.disabled = not tutorial.can_run()
	var counts = Incidents.counts(world)
	map_legend.text = "Rouge : touchés · Véhicules : échanges du jour · 24 régions fictives"
	if world.crises_enabled:
		map_legend.text = "Aléas locaux : %d · mondiaux : %d · F4 : localiser" % [counts.local,counts.global]
		incident_button.disabled = counts.local == 0
		incident_button.tooltip_text = "Localiser l'aléa local suivant : repère, région ou liaison. Les effets mondiaux restent dans Monde [F3]."
	var lines = Incidents.active_lines(world)
	var climate = "Phase %s · %.0f °C fictifs · Remède de phase ×%.2f\n" % [world.phase.name, world.phase.temperature, world.phase.cure_multiplier] if world.scenario.id != "standard" else ""
	effects_label.text = climate + "Événements actifs\n" + ("Aucun effet temporaire." if lines.is_empty() else "\n".join(lines))
	map_view.refresh()
	map_view.motion_enabled = not reduced_motion and not paused and world.outcome.is_empty()

func _process(delta: float) -> void:
	advance_time(delta)

func advance_time(delta: float) -> void:
	if tutorial != null and not tutorial.can_run(): return
	if screen != "game" or paused or not world.outcome.is_empty():
		return
	elapsed += delta * speed
	# Bound work per frame while preserving the accumulated time.
	var steps = 0
	while elapsed >= 0.5 and steps < 16:
		elapsed -= 0.5
		var detected_before = world.detected_count()
		world.step()
		if world.detected_count() > detected_before: feedback.play_cue("alert")
		if world.day % 10 == 0 or not world.outcome.is_empty(): autosave()
		steps += 1
		if tutorial != null and tutorial.after_step(world):
			paused = true
			elapsed = 0.0
			break
		if not world.outcome.is_empty():
			paused = true
			feedback.play_cue("outcome")
			show_result()
			return
		if (World.Decisions.pending(world) and world.day == World.Decisions.definition().start_day) or (World.Tactics.pending(world) and world.tactics.response.opened == world.day):
			show_decision()
			return
	_refresh()

func show_result() -> void:
	screen = "result"
	paused = true
	_reset_screen("Objectif atteint" if world.outcome == "victory" else "Fin de partie", world.outcome_text())
	body.add_child(_label("Jour %d\nPopulation touchée : %.1f %%\nRemède : %.1f %%\nScore : %d" % [world.day, world.coverage() * 100, world.cure, world.score()], 28))
	body.add_child(_label("%s · %s · Score = max(0, couverture × 10 000 − jours × 10) ×%.2f." % [world.scenario.name, world.difficulty.name, world.difficulty.score_multiplier], 16, MUTED))
	if not world.objective.is_empty():
		var optional = _label("Objectif facultatif · " + World.Objectives.summary(world), 16, MUTED)
		optional.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_child(optional)
	if not world.decision.is_empty(): body.add_child(_label(World.Decisions.summary(world),16,MUTED))
	var log = RichTextLabel.new()
	log.add_theme_font_size_override("normal_font_size",20 if reading_large else 16)
	log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log.text = "\n".join(world.journal)
	body.add_child(log)
	var restart = _button("Rejouer avec les mêmes choix", restart_game, body)
	_button("Choisir une autre région", show_menu, body)
	_button("Sauvegardes", open_saves, body)
	_button("Monde et actualités [F3]",open_overview,body)
	_button("Aide [F1]", open_help, body)
	restart.grab_focus()

func open_overview() -> void:
	if world.regions.is_empty() or tutorial != null: return
	if screen == "overview":
		close_overview()
		return
	overview_return = "result" if screen == "result" else "game"
	show_overview()
func close_overview() -> void:
	if overview_return == "result" or not world.outcome.is_empty(): show_result()
	else: show_game()
func show_overview() -> void:
	load("res://scripts/ui/overview_view.gd").build(self)

func reversed_news() -> Array[String]:
	var news = world.journal.duplicate()
	news.reverse()
	return news

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_press_active = event.pressed
	if is_instance_valid(pending_dialog) and pending_dialog.visible: return
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		if screen == "help": close_help()
		elif screen == "evolution": close_evolution()
		elif screen == "overview": close_overview()
		elif screen == "saves": close_saves()
		elif screen == "decision": show_game()
		elif tutorial != null: finish_tutorial()
		else: show_menu()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_E and screen in ["game","evolution"] and not (get_viewport().gui_get_focus_owner() is LineEdit):
		open_evolution()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F1:
		open_help()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F2 and screen == "game" and (not world.decision.is_empty() or World.Tactics.pending(world)):
		show_decision()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F3 and screen in ["game","result","overview"]:
		open_overview()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F4 and screen == "game" and world.crises_enabled:
		map_view.focus_next_incident()
		get_viewport().set_input_as_handled()
	elif screen == "game":
		if event.keycode == KEY_SPACE:
			toggle_pause()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_1, KEY_2, KEY_4]:
			speed = {KEY_1: 1, KEY_2: 2, KEY_4: 4}[event.keycode]
			_refresh()
