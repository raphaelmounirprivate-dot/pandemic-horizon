extends Control

const World = preload("res://scripts/simulation/world.gd")
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
const GameView = preload("res://scripts/ui/game_view.gd")
const SavesView = preload("res://scripts/ui/saves_view.gd")
const TutorialFlow = preload("res://scripts/ui/tutorial_flow.gd")
const HelpView = preload("res://scripts/ui/help_view.gd")
const GameClock = preload("res://scripts/ui/game_clock.gd")
const Shortcuts = preload("res://scripts/ui/shortcuts.gd")
const Preferences = preload("res://scripts/ui/preferences.gd")
const EvolutionFlow = preload("res://scripts/ui/evolution_flow.gd")
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
var agent_id: String = ""
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
var setup_step = 1
var scenario_cards: Dictionary = {}
var difficulty_cards: Dictionary = {}
var start_locked = false
var start_map: Control
var start_detail: Label
var setup_next: Button
var setup_summary: Label
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
var evolution_points: Label
var evolution_points_next: Label
var evolution_return_paused = true
var result_cards: Dictionary = {}
var result_moments: Label
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
var help_buttons: Array = []
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
	Preferences.load_into(self)

func _save_preferences() -> void:
	Preferences.save_from(self)

func open_help() -> void:
	if screen == "help":
		close_help()
		return
	help_return = screen
	help_topic = 0
	show_help()

func show_help() -> void:
	HelpView.build(self)

func select_help_topic(index: int) -> void:
	HelpView.select(self, index)

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
		"setup": show_new_game(setup_step)
		"overview": show_overview()
		_: show_menu()

func start_tutorial() -> void:
	TutorialFlow.start(self)

func _restore_tutorial_session() -> String:
	return TutorialFlow.restore(self)

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
	SavesView.save_manual(self, slot)

func load_saved(slot: String) -> void:
	SavesView.load_slot(self, slot)

func show_saves() -> void:
	SavesView.build(self)

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
	theme = Preferences.theme()

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
	heading.add_child(_label("PROTOTYPE " + ".".join(str(ProjectSettings.get_setting("application/config/version")).split(".").slice(0, 2)), 16, MUTED))
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

## "Nouvelle partie" in three steps; every choice is applied immediately.
func show_new_game(step: int = 1) -> void:
	MenuView.build_setup(self,step)

func choose_scenario(id: String) -> void:
	scenario_id = id
	show_new_game(1)
	if scenario_cards.has(id): scenario_cards[id].grab_focus()

func choose_difficulty(id: String) -> void:
	difficulty_id = id
	MenuView.update_choices(self,_menu_catalog())
	if difficulty_cards.has(id): difficulty_cards[id].grab_focus()

func choose_start(id: String) -> void:
	if start_locked: return
	start_id = id
	if is_instance_valid(start_map):
		for i in range(start_map.world.regions.size()):
			if start_map.world.regions[i].id == id: start_map.selected = i
	MenuView.refresh_start(self)

func setup_back() -> void:
	if setup_step <= 1: show_menu()
	else: show_new_game(setup_step-1)

func setup_forward() -> void:
	if setup_step >= MenuView.STEPS.size(): start_game()
	else: show_new_game(setup_step+1)

func world_scenario_name() -> String:
	for item in _menu_catalog().scenarios:
		if item.id == scenario_id: return item.name
	return scenario_id

func difficulty_name() -> String:
	for item in _menu_catalog().difficulties:
		if item.id == difficulty_id: return item.name
	return difficulty_id

func region_label(id: String) -> String:
	for region in JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH)).regions:
		if region.id == id: return region.name
	return id

func show_settings() -> void:
	load("res://scripts/ui/settings_view.gd").build(self)

func start_game() -> void:
	reset_map_camera = true
	var error = world.start_with({"start": start_id, "seed": simulation_seed, "scenario": scenario_id, "difficulty": difficulty_id, "objective": objective_id, "decision": decision_enabled, "expanded": advanced_mode, "crises": crises_mode, "reactive": reactive_mode, "agent": agent_id})
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
	agent_id = world.strategy.get("agent", "")
	reactive_mode = world.tactics_enabled
	simulation_seed = world.rng.seed
	start_game()

func show_game() -> void:
	GameView.build(self)

func buy_evolution(id: String) -> void:
	EvolutionFlow.buy(self, id)

func select_evolution(id: String) -> void:
	EvolutionFlow.select(self, id)

func purchase_reason_for(id: String) -> String:
	return EvolutionFlow.purchase_reason(self, id)

func open_evolution(id: String = "") -> void:
	EvolutionFlow.open(self, id)

func show_evolution() -> void:
	EvolutionView.build(self)

func show_evolution_family(family_id: String) -> void:
	EvolutionFlow.show_family(self, family_id)

func close_evolution() -> void:
	EvolutionFlow.close(self)

func show_decision() -> void:
	if tutorial != null or (world.decision.is_empty() and not World.Tactics.pending(world) and not World.Strategy.pending(world)): return
	paused = true
	elapsed = 0.0
	show_game()
func toggle_pause() -> void:
	GameClock.toggle_pause(self)

func set_speed(value: int) -> void:
	GameClock.set_speed(self, value)

func _refresh() -> void:
	GameView.refresh(self)

func _process(delta: float) -> void:
	advance_time(delta)
	if is_instance_valid(feedback): feedback.set_ambience(screen == "game" and not paused and not world.strategy.is_empty(), world.cure / 100.0)

func advance_time(delta: float) -> void:
	GameClock.advance(self, delta)

func show_result() -> void:
	preload("res://scripts/ui/result_view.gd").build(self)

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
	Shortcuts.handle(self, event)
