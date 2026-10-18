extends Control

const World = preload("res://scripts/simulation/world.gd")
const MapView = preload("res://scripts/ui/region_map.gd")
const SaveStore = preload("res://scripts/persistence/save_store.gd")
const Tutorial = preload("res://scripts/ui/tutorial.gd")
const Help = preload("res://scripts/ui/help.gd")
const Incidents = preload("res://scripts/ui/incident_view.gd")
var incident_button: Button
var map_legend: Label
const INK = Color("e1eee9")
const MUTED = Color("a7c4c9")
const ACCENT = Color("69d6bd")
const AMBER = Color("efbc70")
const CONFIG_PATH = "user://settings.cfg"

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
var evolution_tree: GridContainer
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
	var error = world.start("boreale")
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

func reveal_evolution_group(_group: Control) -> void:
	pass # All upgrades are permanently visible.

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
	paused = true
	elapsed = 0.0
	screen = "saves"
	_reset_screen("Sauvegardes d'entraînement" if tutorial != null else "Sauvegardes", "Fichiers d'essai séparés : aucune sauvegarde du joueur n'est modifiée." if tutorial != null else "Sauvegardes 0.12 · Parties 0.7 à 0.11 compatibles · Tarif 0.11 conservé.")
	body.add_child(_label("Enregistrez dans un emplacement manuel, puis chargez-le pour terminer l'exercice." if tutorial != null else "Le chargement remplace la partie en mémoire et reprend en pause.\nL'automatique est actualisée tous les 10 jours, au menu et à la fermeture.", 18, MUTED))
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	body.add_child(scroll)
	var rows = VBoxContainer.new()
	var training_action: Button
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 20)
	scroll.add_child(rows)
	for slot in SaveStore.SLOTS:
		var result = save_store.load_slot(slot)
		var group = VBoxContainer.new()
		rows.add_child(group)
		var name_text = "Automatique" if slot == "auto" else "Emplacement " + slot.trim_prefix("slot")
		var summary = result.error
		if result.error.is_empty():
			summary = "%s · %s · Jour %d · %s" % [result.world.scenario.name, result.world.difficulty.name, result.world.day, result.saved_at.replace("T", " à ")]
			if result.get("backup", false): summary += " · Copie de secours"
			elif result.has("warning"): summary += " · Ancienne partie compatible"
		var label = _label(name_text + " — " + summary, 18)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		group.add_child(label)
		var actions = HBoxContainer.new()
		group.add_child(actions)
		if slot != "auto":
			var save_button = _button("Enregistrer ici", func():
				if FileAccess.file_exists(save_store._path(slot)) or FileAccess.file_exists(save_store._path(slot) + ".bak"):
					confirm_action("Remplacer " + name_text.to_lower() + " par la partie en mémoire ?", func(): save_manual(slot))
				else: save_manual(slot)
			, actions)
			save_button.disabled = world.regions.is_empty()
			if tutorial != null and tutorial.saved_slot.is_empty() and training_action == null: training_action = save_button
		var load_button = _button("Charger", func():
			if not world.regions.is_empty():
				confirm_action("Charger " + name_text.to_lower() + " et remplacer la partie en mémoire ?", func(): load_saved(slot))
			else: load_saved(slot)
		, actions)
		load_button.disabled = not result.error.is_empty()
		if tutorial != null and tutorial.saved_slot == slot: training_action = load_button
	var notice = _label(save_notice if not save_notice.is_empty() else "Une copie de la sauvegarde précédente est conservée après chaque remplacement.", 16, AMBER)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(notice)
	_button("Retour", close_saves, body).grab_focus()
	if training_action != null: training_action.grab_focus()

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
	start_game()
	if screen != "game" or world.totals().active != 200 or world.regions.size() != 24 or map_view.buttons.size() != 24:
		get_tree().quit(1)
		return
	if world.route_mode(["boreale", "centrale"]) != "sea" or not is_equal_approx(world.transport_factor(["centrale", "meridien"]), 1.2):
		get_tree().quit(1)
		return
	world.points = 100
	if world.purchase("mobility").is_empty():
		get_tree().quit(1)
		return
	buy_evolution("transmission")
	buy_evolution("mobility")
	buy_evolution("discretion")
	toggle_pause()
	for target_day in [23, 26, 32, 44]:
		while world.day < target_day and screen == "game":
			advance_time(0.5)
		var closed = not world.route_is_open(["boreale", "centrale"])
		if screen != "game" or closed != (target_day in [23, 26]):
			get_tree().quit(1)
			return
	if not world.active_events.any(func(e): return e.id == "research_boost") or world.detected_count() == 0:
		get_tree().quit(1)
		return
	if not is_equal_approx(world.transport_factor(["centrale", "meridien"]), 0.72):
		get_tree().quit(1)
		return
	for i in range(500):
		advance_time(0.5)
	if screen != "result" or world.outcome != "victory":
		get_tree().quit(1)
		return
	start_game()
	toggle_pause()
	for i in range(500):
		advance_time(0.5)
	if screen != "result" or world.outcome != "defeat_cure":
		get_tree().quit(1)
		return
	scenario_id = "degel2042"
	difficulty_id = "normal"
	start_id = "boreale"
	start_game()
	if world.phase.id != "isolation" or world.evolutions.size() != 9 or world.route_is_open(["boreale", "orient"]):
		get_tree().quit(1)
		return
	toggle_pause()
	for target_day in [12, 28, 36, 39, 55]:
		while world.day < target_day and screen == "game":
			advance_time(0.5)
		var expected_closed = target_day in [28, 36]
		if screen != "game" or (not world.route_is_open(["boreale", "centrale"])) != expected_closed:
			get_tree().quit(1)
			return
	if world.phase.id != "mobilization" or world.phase.cure_multiplier != 1.35:
		get_tree().quit(1)
		return
	world.points = 100
	for id in world.evolutions: buy_evolution(id)
	if world.purchased.size() != 7 or world.specialization_id() != "land_network":
		get_tree().quit(1)
		return
	difficulty_id = "hard"
	start_game()
	if world.difficulty.cure_multiplier != 1.3:
		get_tree().quit(1)
		return
	# Exercise persistence inside the standalone export, away from real player slots.
	var smoke_store = SaveStore.new()
	smoke_store.directory = "user://smoke-persistence"
	for slot in SaveStore.SLOTS:
		for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(smoke_store._path(slot) + suffix): DirAccess.remove_absolute(smoke_store._path(slot) + suffix)
	for i in range(33): world.step()
	if not smoke_store.save_slot("slot1", world).is_empty():
		get_tree().quit(1)
		return
	var restored = smoke_store.load_slot("slot1")
	if not restored.error.is_empty():
		get_tree().quit(1)
		return
	for i in range(20):
		world.step()
		restored.world.step()
	if world.regions != restored.world.regions or world.cure != restored.world.cure or world.rng.state != restored.world.rng.state:
		get_tree().quit(1)
		return
	DirAccess.remove_absolute(smoke_store._path("slot1"))
	var player_world = world
	training_directory = "user://smoke-training"
	start_tutorial()
	toggle_pause()
	advance_time(0.5)
	next_lesson()
	select_region(2)
	next_lesson()
	buy_evolution("transmission")
	next_lesson()
	select_region(0)
	next_lesson()
	toggle_pause()
	advance_time(20)
	toggle_pause()
	advance_time(20)
	next_lesson()
	open_saves()
	save_manual("slot1")
	load_saved("slot1")
	if tutorial == null or not tutorial.ready or world.day != 32:
		get_tree().quit(1)
		return
	next_lesson()
	if tutorial != null or world != player_world or not paused:
		get_tree().quit(1)
		return
	open_help()
	if screen != "help" or help_text.text.is_empty():
		get_tree().quit(1)
		return
	close_help()
	show_settings()
	show_menu()
	if screen != "menu":
		get_tree().quit(1)
		return
	var optional_world = World.new()
	if not optional_world.start("boreale", 2042, null, null, "standard", "normal", null, null, "first_relays").is_empty():
		get_tree().quit(1)
		return
	for i in range(60):
		for id in ["transmission", "mobility", "discretion"]:
			if id not in optional_world.purchased:
				optional_world.purchase(id)
				break
		optional_world.step()
	var optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if optional_world.objective.status != "completed" or optional_world.objective.resolved_day != 49 or not optional_loaded.error.is_empty() or optional_loaded.world.objective != optional_world.objective:
		get_tree().quit(1)
		return
	optional_world.start("boreale", 2042, null, null, "standard", "normal", null, null, "first_relays")
	for i in range(60): optional_world.step()
	if optional_world.objective.status != "failed" or optional_world.objective.resolved_day != 50:
		get_tree().quit(1)
		return
	optional_world.start("boreale",2042,null,null,"degel2042","normal",null,null,"arctic_relays")
	for i in range(55):
		for id in ["transmission","mobility","discretion"]:
			if id not in optional_world.purchased:
				optional_world.purchase(id)
				break
		optional_world.step()
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if optional_world.objective.status != "completed" or not optional_loaded.error.is_empty() or optional_loaded.world.objective != optional_world.objective:
		get_tree().quit(1)
		return
	optional_world.start("boreale",2042,null,null,"degel2042","normal",null,null,"",true)
	for i in range(28): optional_world.step()
	if not World.Decisions.choose(optional_world,"support").is_empty():
		get_tree().quit(1)
		return
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or optional_loaded.world.points != 20:
		get_tree().quit(1)
		return
	for i in range(13): optional_loaded.world.step()
	if optional_loaded.world.decision.status != "expired":
		get_tree().quit(1)
		return
	optional_world.start("boreale",2042,null,null,"degel2042","normal",null,null,"",true)
	optional_world.decision_profile = "0.11"
	optional_world.decision_rules = World.Decisions.legacy_definition()
	for i in range(28): optional_world.step()
	if not World.Decisions.choose(optional_world,"support").is_empty() or optional_world.points != 17:
		get_tree().quit(1)
		return
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or optional_loaded.world.decision_profile != "0.11" or World.Decisions.option("support",optional_loaded.world).cost != 6:
		get_tree().quit(1)
		return
	if not optional_world.start("boreale",2042,null,null,"degel2042","normal",null,null,"arctic_relays",true,true).is_empty():
		get_tree().quit(1)
		return
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or not optional_loaded.world.expanded_content or optional_loaded.world.evolutions.size() != 21:
		get_tree().quit(1)
		return
	advanced_mode = true
	scenario_id = "degel2042"
	start_game()
	reduced_motion = true
	reading_large = true
	paused = false
	advance_time(0.5)
	if world.day != 1 or map_view.motion_enabled or feedback.cues.size() != 3:
		get_tree().quit(1)
		return
	open_overview()
	open_help()
	if help_text.get_theme_font_size("normal_font_size") != 24:
		get_tree().quit(1)
		return
	if not optional_world.start("centrale",777,null,null,"fragile2042","normal",null,null,"",false,true,null,true).is_empty():
		get_tree().quit(1)
		return
	for day in range(40): optional_world.step()
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or not optional_loaded.world.crises_enabled or optional_loaded.world.event_definitions != optional_world.event_definitions:
		get_tree().quit(1)
		return
	world = optional_loaded.world
	show_game()
	if incident_button == null or not "mondiaux" in map_legend.text or not Incidents.entries(world).all(func(e): return e.start_day <= world.day):
		get_tree().quit(1)
		return
	if not optional_world.start("centrale",2042,null,null,"fragile2042","normal",null,null,"",false,true,null,true,null,true).is_empty():
		get_tree().quit(1)
		return
	for day in range(55):
		for id in ["transmission","mobility","discretion"]:
			if id not in optional_world.purchased:
				optional_world.purchase(id)
				break
		if World.Tactics.pending(optional_world): World.Tactics.choose(optional_world,"endure")
		optional_world.step()
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or not optional_loaded.world.tactics_enabled or optional_loaded.world.tactics != optional_world.tactics:
		get_tree().quit(1)
		return
	world = optional_loaded.world
	show_game()
	if not "Double relais" in objective_details.text:
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
	if screen == "game": body.add_theme_constant_override("separation",6)
	margin.add_child(body)
	var heading = HBoxContainer.new()
	body.add_child(heading)
	var title_label = _label(title, 30)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title_label)
	heading.add_child(_label("PROTOTYPE 0.22", 16, MUTED))
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
	if tutorial != null: _restore_tutorial_session()
	if screen == "game" or screen == "result": autosave()
	screen = "menu"
	paused = true
	elapsed = 0.0
	_reset_screen("Pandemic Horizon", "Un monde connecté. Des choix qui changent la trajectoire.")
	var center = HBoxContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var presentation = VBoxContainer.new()
	presentation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_child(presentation)
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 0
	presentation.add_child(spacer)
	var identity = HBoxContainer.new()
	presentation.add_child(identity)
	var emblem = load("res://scripts/ui/agent_emblem.gd").new()
	emblem.custom_minimum_size = Vector2(72,72)
	emblem.tooltip_text = "NACRE · Emblème abstrait de réseau, sans représentation biologique réelle."
	identity.add_child(emblem)
	identity.add_child(_label("NACRE\nChaque région compte.",26))
	var description = _label("Agent fictif dans 24 régions reliées.\nObjectif : toucher 90 % avant le remède.",18)
	presentation.add_child(description)
	menu_scenario_detail = _label("", 16, MUTED)
	menu_scenario_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	presentation.add_child(menu_scenario_detail)
	menu_difficulty_detail = _label("", 16, AMBER)
	presentation.add_child(menu_difficulty_detail)
	objective_choice = CheckButton.new()
	objective_choice.text = "Objectif facultatif : Premiers relais"
	objective_choice.custom_minimum_size.y = 44
	objective_choice.button_pressed = not objective_id.is_empty()
	objective_choice.toggled.connect(func(enabled): objective_id = World.Objectives.for_scenario(scenario_id).get("id","") if enabled else "")
	var optional_choices = HBoxContainer.new()
	presentation.add_child(optional_choices)
	objective_choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	optional_choices.add_child(objective_choice)
	decision_choice = CheckButton.new()
	decision_choice.text = "Décision logistique (J28)"
	decision_choice.custom_minimum_size.y = 44
	decision_choice.button_pressed = decision_enabled
	decision_choice.tooltip_text = "Événement facultatif Dégel : options, coûts et effets présentés au jour 28."
	decision_choice.toggled.connect(func(enabled): decision_enabled = enabled)
	optional_choices.add_child(decision_choice)
	menu_objective_detail = _label("", 16, MUTED)
	menu_objective_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	presentation.add_child(menu_objective_detail)
	var profile_choices = HBoxContainer.new()
	presentation.add_child(profile_choices)
	var learning = HBoxContainer.new()
	presentation.add_child(learning)
	_button("Tutoriel guidé", start_tutorial, learning)
	_button("Aide [F1]", open_help, learning)
	advanced_choice = CheckButton.new()
	advanced_choice.text = "Catalogue enrichi"
	advanced_choice.custom_minimum_size.y = 44
	advanced_choice.button_pressed = advanced_mode
	advanced_choice.tooltip_text = "Profil distinct : 18 évolutions de base, 21 dans Dégel, événements supplémentaires. Les parties classiques gardent leurs règles."
	advanced_choice.toggled.connect(func(enabled):
		advanced_mode = enabled
		_update_menu_choices(_menu_catalog()))
	profile_choices.add_child(advanced_choice)
	crises_choice = CheckButton.new()
	crises_choice.text = "Aléas et résilience (+3)"
	crises_choice.custom_minimum_size.y = 44
	crises_choice.button_pressed = crises_mode
	crises_choice.tooltip_text = "Douze aléas tirés par graine, huit types favorables/défavorables à la diffusion et trois compétences de protection. Active le catalogue enrichi."
	crises_choice.toggled.connect(func(enabled):
		crises_mode = enabled
		_update_menu_choices(_menu_catalog()))
	profile_choices.add_child(crises_choice)
	reactive_choice = CheckButton.new()
	reactive_choice.text = "Crises réactives"
	reactive_choice.custom_minimum_size.y = 44
	reactive_choice.button_pressed = reactive_mode
	reactive_choice.tooltip_text = "Ciblage des foyers actifs, réponse à la première panne aérienne et Double relais obligatoire dans Réseaux fragiles. Profil de sauvegarde distinct."
	reactive_choice.toggled.connect(func(enabled):
		reactive_mode = enabled
		_update_menu_choices(_menu_catalog()))
	profile_choices.add_child(reactive_choice)
	learning.add_child(_label("Graine",16,MUTED))
	var seed_input = SpinBox.new()
	seed_input.name = "seed_input"
	seed_input.min_value = 0
	seed_input.max_value = 999999999
	seed_input.step = 1
	seed_input.value = simulation_seed
	seed_input.custom_minimum_size = Vector2(140,44)
	seed_input.tooltip_text = "Même graine et mêmes choix : même tirage des aléas. Recommencer conserve cette graine."
	seed_input.value_changed.connect(func(value): simulation_seed = int(value))
	learning.add_child(seed_input)
	_button("Autre",func(): seed_input.value = abs((str(Time.get_unix_time_from_system())+str(Time.get_ticks_usec())).hash()) % 1000000000,learning)
	var actions = VBoxContainer.new()
	actions.custom_minimum_size.x = 320
	center.add_child(actions)
	var data = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH))
	var error = World.validate_data(data)
	var catalog: Variant = _menu_catalog()
	if error.is_empty():
		error = World.Scenarios.validate(catalog, data, World.Content.load_files())
	if not error.is_empty():
		actions.add_child(_label(error))
		_button("Quitter", func(): get_tree().quit(), actions)
		return
	actions.add_child(_label("Scénario", 18))
	scenario_choice = OptionButton.new()
	scenario_choice.custom_minimum_size.y = 44
	for i in range(catalog.scenarios.size()):
		scenario_choice.add_item(catalog.scenarios[i].name)
		scenario_choice.set_item_metadata(i, catalog.scenarios[i].id)
		if catalog.scenarios[i].id == scenario_id: scenario_choice.select(i)
	scenario_choice.item_selected.connect(func(index):
		scenario_id = scenario_choice.get_item_metadata(index)
		_update_menu_choices(catalog)
	)
	actions.add_child(scenario_choice)
	actions.add_child(_label("Difficulté", 18))
	difficulty_choice = OptionButton.new()
	difficulty_choice.custom_minimum_size.y = 44
	for i in range(catalog.difficulties.size()):
		difficulty_choice.add_item(catalog.difficulties[i].name)
		difficulty_choice.set_item_metadata(i, catalog.difficulties[i].id)
		if catalog.difficulties[i].id == difficulty_id: difficulty_choice.select(i)
	difficulty_choice.item_selected.connect(func(index):
		difficulty_id = difficulty_choice.get_item_metadata(index)
		_update_menu_choices(catalog)
	)
	actions.add_child(difficulty_choice)
	actions.add_child(_label("Région de départ", 18))
	var choices = OptionButton.new()
	choices.custom_minimum_size.y = 44
	start_choice = choices
	for i in range(data.regions.size()):
		choices.add_item(data.regions[i].name)
		choices.set_item_metadata(i, data.regions[i].id)
		if data.regions[i].id == start_id:
			choices.select(i)
	choices.item_selected.connect(func(index): start_id = choices.get_item_metadata(index))
	actions.add_child(choices)
	_update_menu_choices(catalog)
	var launch = _button("Nouvelle partie", start_game, actions)
	if not world.regions.is_empty() and world.outcome.is_empty():
		_button("Reprendre la partie", show_game, actions)
	_button("Paramètres", show_settings, actions)
	_button("Sauvegardes", open_saves, actions)
	_button("Quitter", request_quit, actions)
	var footer = _label("Simulation abstraite · Les chiffres sont des paramètres de jeu fictifs.\n" + (save_notice if not save_notice.is_empty() else "Sauvegardes locales disponibles depuis le menu ou la partie."), 16, MUTED)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(footer)
	launch.grab_focus()

func _menu_catalog() -> Dictionary:
	return World.Crises.catalog(World.Scenarios.load_catalog())

func _update_menu_choices(catalog: Dictionary) -> void:
	if reactive_mode: crises_mode = true
	if scenario_id == "fragile2042": crises_mode = true
	if crises_mode: advanced_mode = true
	crises_choice.set_pressed_no_signal(crises_mode)
	crises_choice.disabled = scenario_id == "fragile2042" or reactive_mode
	advanced_choice.set_pressed_no_signal(advanced_mode)
	advanced_choice.disabled = crises_mode
	decision_choice.visible = scenario_id == "degel2042"
	if scenario_id != "degel2042": decision_enabled = false
	decision_choice.set_pressed_no_signal(decision_enabled)
	var optional = World.Objectives.for_scenario(scenario_id)
	objective_choice.disabled = optional.is_empty()
	objective_choice.text = "Objectif facultatif : " + optional.get("name","indisponible")
	if objective_id != optional.get("id",""):
		objective_id = ""
	objective_choice.set_pressed_no_signal(not objective_id.is_empty())
	menu_objective_detail.text = World.Objectives.description(optional)
	if reactive_mode:
		menu_objective_detail.text = "Crises réactives : choix à la première panne aérienne."
		if scenario_id == "fragile2042": menu_objective_detail.text += "\nObligatoire : Centrale → Méridien et Savane, 6 000 unités chacun avant J60 inclus."
	for item in catalog.scenarios:
		if item.id == scenario_id:
			start_choice.disabled = item.forced_start != ""
			if item.forced_start != "": start_id = item.forced_start
			menu_scenario_detail.text = item.description
			menu_scenario_detail.text += "\n" + ("Profil enrichi : %d évolutions · %d événements programmés." % [21 if scenario_id == "degel2042" else 18,12 if scenario_id == "degel2042" else 14] if advanced_mode else "Profil classique : %d évolutions · règles historiques conservées." % [9 if scenario_id == "degel2042" else 6])
			if crises_mode: menu_scenario_detail.text = item.description + "\nProfil aléas : %d compétences · 12 aléas + %d événements fixes.\nConséquences favorables ou défavorables à la diffusion." % [24 if scenario_id == "degel2042" else 21,12 if scenario_id == "degel2042" else 14]
	for i in range(start_choice.item_count):
		if start_choice.get_item_metadata(i) == start_id: start_choice.select(i)
	for item in catalog.difficulties:
		if item.id == difficulty_id:
			menu_difficulty_detail.text = "%s · Recherche ×%.2f · Seuil de détection ×%.2f\nScore ×%.2f · Objectif : 90 %% avant le remède" % [item.name, item.cure_multiplier, item.detection_multiplier, item.score_multiplier]

func show_settings() -> void:
	screen = "settings"
	paused = true
	_reset_screen("Paramètres", "Préférences de confort conservées sur ce PC, sans modifier la partie.")
	var fullscreen = CheckButton.new()
	fullscreen.text = "Plein écran"
	fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen.custom_minimum_size.y = 48
	fullscreen.toggled.connect(func(enabled):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
		_save_preferences()
	)
	body.add_child(fullscreen)
	for item in [["Réduire les mouvements",reduced_motion,"motion"],["Agrandir le texte de lecture (aide, actualités et bilan)",reading_large,"reading"],["Activer les sons de retour",sounds_enabled,"sound"]]:
		var toggle = CheckButton.new()
		toggle.name = item[2]
		toggle.text = item[0]
		toggle.button_pressed = item[1]
		toggle.custom_minimum_size.y = 44
		toggle.toggled.connect(func(active):
			match item[2]:
				"motion": reduced_motion = active
				"reading": reading_large = active
				"sound": sounds_enabled = active
			_save_preferences()
			if item[2] == "sound" and active: feedback.play_cue("purchase")
		)
		body.add_child(toggle)
	var volume_row = HBoxContainer.new()
	volume_row.name = "audio_volume"
	body.add_child(volume_row)
	var volume_label = _label("Volume : %d %%" % roundi(sound_volume*100),18)
	volume_label.custom_minimum_size.x = 160
	volume_row.add_child(volume_label)
	var volume = HSlider.new()
	volume.name = "volume"
	volume.min_value = 0
	volume.max_value = 1
	volume.step = 0.05
	volume.value = sound_volume
	volume.custom_minimum_size = Vector2(300,44)
	volume.tooltip_text = "Volume des sons facultatifs ; zéro coupe le son."
	volume.value_changed.connect(func(level):
		sound_volume = level
		volume_label.text = "Volume : %d %%" % roundi(level*100)
		_save_preferences()
	)
	volume_row.add_child(volume)
	body.add_child(_label("Espace : pause · 1 / 2 / 4 : vitesse · F1 : aide · F3 : monde\nÉchap : retour · Tab / Maj + Tab : parcourir · Entrée : activer",18))
	status_label = _label("Les mouvements réduits figent les véhicules ; la simulation continue.\nLes sons sont facultatifs : chaque action conserve son retour visuel.", 18, MUTED)
	body.add_child(status_label)
	_button("Retour au menu", show_menu, body)
	fullscreen.grab_focus()

func start_game() -> void:
	reset_map_camera = true
	var error = world.start(start_id, simulation_seed, null, null, scenario_id, difficulty_id, null, null, objective_id,decision_enabled,advanced_mode,null,crises_mode,null,reactive_mode)
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
	sidebar.custom_minimum_size.x = 500
	sidebar.add_theme_constant_override("separation",4)
	content.add_child(sidebar)
	region_details = _label("",14)
	sidebar.add_child(region_details)
	transport_details = _label("",13,MUTED)
	sidebar.add_child(transport_details)
	sidebar.add_child(_label("Évolutions · liens de la sélection" if world.expanded_content else "Évolutions · arbre complet",20))
	specialization_details = _label("",13,AMBER)
	specialization_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar.add_child(specialization_details)
	var grid = load("res://scripts/ui/evolution_tree.gd").new()
	evolution_tree = grid
	grid.world = world
	grid.columns = 6 if world.expanded_content else 3
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",10 if world.expanded_content else 14)
	if world.expanded_content:
		var graph_margin = MarginContainer.new()
		graph_margin.add_theme_constant_override("margin_top",8)
		sidebar.add_child(graph_margin)
		graph_margin.add_child(grid)
	else: sidebar.add_child(grid)
	for id in world.evolutions:
		var group = VBoxContainer.new()
		group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		group.add_theme_constant_override("separation",3)
		grid.add_child(group)
		var button = load("res://scripts/ui/evolution_node.gd").new()
		button.evolution_id = id
		button.custom_minimum_size.y = 44
		button.pressed.connect(func():
			select_evolution(id)
			if not evolution_purchase.disabled: evolution_purchase.grab_focus())
		button.focus_entered.connect(func(): select_evolution(id))
		group.add_child(button)
		button.add_theme_font_size_override("font_size",12 if world.expanded_content else 13)
		for state in ["normal","hover","pressed","disabled","focus"]:
			var style = button.get_theme_stylebox(state).duplicate()
			style.content_margin_top = 4
			style.content_margin_bottom = 4
			style.content_margin_left = 26 if world.expanded_content else 28
			style.content_margin_right = 12 if world.expanded_content else 8
			button.add_theme_stylebox_override(state,style)
		button.tooltip_text = world.evolutions[id].effect
		evolution_buttons[id] = button
		grid.nodes[id] = group
		var reason = _label("",13,AMBER)
		reason.clip_text = true
		group.add_child(reason)
		reason.visible = not world.expanded_content
		evolution_reasons[id] = reason
	evolution_detail = _label("",13,MUTED)
	evolution_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar.add_child(evolution_detail)
	evolution_purchase = _button("",func(): buy_evolution(selected_evolution),sidebar)
	evolution_purchase.add_theme_font_size_override("font_size",13)
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
		elif tutorial.stage == 2: initial_focus = evolution_buttons.transmission
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
	_refresh()
	if not error.is_empty():
		status_label.text = error
	if evolution_buttons.has(id) and evolution_buttons[id].has_focus():
		var group = evolution_buttons[id].get_parent()
		reveal_evolution_group(group)

func select_evolution(id: String) -> void:
	selected_evolution = id
	if is_instance_valid(evolution_purchase): _refresh()

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
				else: decision_notice.text = error
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
	var specialization = world.specialization_id()
	specialization_details.text = "Après Mobilité : une seule spécialisation au choix." if specialization.is_empty() else "Spécialisation : " + world.evolutions[specialization].name
	for id in evolution_buttons:
		var evolution = world.evolutions[id]
		var acquired = id in world.purchased
		var short_names = {"transmission":"Diffus.","mobility":"Mobil.","discretion":"Discr.","land_network":"Terre","air_bridge":"Air","sea_logistics":"Mer","polar":"Polaire","seasonal":"Saison","resilience":"Climat"}
		var displayed_name = evolution.get("short",short_names.get(id,evolution.name)) if world.expanded_content else evolution.name
		evolution_buttons[id].text = "%s\n%s" % [displayed_name, "acquise" if acquired else "%d pts" % evolution.cost]
		# Keep insufficient purchases focusable so keyboard users can read the reason.
		evolution_buttons[id].disabled = tutorial != null and (tutorial.stage != 2 or id != "transmission")
		evolution_buttons[id].add_theme_color_override("font_color",ACCENT if id == selected_evolution or acquired else INK)
		evolution_buttons[id].selected_node = id == selected_evolution
		evolution_buttons[id].blocked = not world.purchase_reason(id).is_empty() and not acquired
		evolution_buttons[id].queue_redraw()
		var reason = world.purchase_reason(id)
		if tutorial != null and not acquired and (tutorial.stage != 2 or id != "transmission"):
			reason = "Hors exercice" + (" · " + reason if not reason.is_empty() else "")
		evolution_buttons[id].tooltip_text = evolution.name + " · " + evolution.effect + " " + reason
		var short_reason = "Prérequis manquant" if reason.begins_with("Prérequis") else ("Incompatible" if "Incompatible" in reason else reason)
		if reason.begins_with("Hors exercice"): short_reason = "Prérequis (exercice)" if "Prérequis" in reason else "Hors exercice"
		evolution_reasons[id].text = "Acquise" if acquired else ("Disponible" if reason.is_empty() else short_reason)
		evolution_reasons[id].add_theme_color_override("font_color", ACCENT if acquired or reason.is_empty() else AMBER)
	if not world.evolutions.has(selected_evolution): selected_evolution = world.evolutions.keys()[0]
	var chosen = world.evolutions[selected_evolution]
	var full_reason = "Acquise" if selected_evolution in world.purchased else world.purchase_reason(selected_evolution)
	if tutorial != null and (tutorial.stage != 2 or selected_evolution != "transmission"): full_reason = "Hors exercice · " + full_reason
	evolution_detail.text = "%s\n%s" % [chosen.effect,"Disponible" if full_reason.is_empty() else full_reason]
	evolution_purchase.text = "Évoluer : %s · %d pts" % [chosen.name,chosen.cost]
	evolution_purchase.disabled = not world.purchase_reason(selected_evolution).is_empty() or (tutorial != null and (tutorial.stage != 2 or selected_evolution != "transmission"))
	evolution_tree.queue_redraw()
	evolution_tree.selected_id = selected_evolution
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
	screen = "overview"
	paused = true
	elapsed = 0.0
	_reset_screen("Monde · Actualités et bilan","%s · %s · Jour %d · %s" % [world.scenario.name,world.difficulty.name,world.day,world.outcome_text()])
	var totals = world.totals()
	body.add_child(_label("Sains : %d · Actifs : %d · Retirés : %d · Touchés : %.1f %% · Remède : %.1f %%" % [totals.healthy,totals.active,totals.removed,world.coverage()*100,world.cure],16))
	if not world.objective.is_empty():
		var objective_line = _label("Objectif facultatif · "+world.Objectives.summary(world),13,MUTED)
		objective_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_child(objective_line)
	history_chart = load("res://scripts/ui/history_chart.gd").new()
	history_chart.world = world
	history_chart.custom_minimum_size.y = 190
	body.add_child(history_chart)
	var columns = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation",16)
	body.add_child(columns)
	var purchase_lines: Array[String] = []
	for purchase in world.purchase_history: purchase_lines.append("J%d · %s · %d pts" % [purchase.day,world.evolutions[purchase.id].name,purchase.cost])
	if purchase_lines.is_empty(): purchase_lines.append("Aucun achat daté enregistré.")
	if world.purchase_history.size() < world.purchased.size(): purchase_lines.append("Dates antérieures absentes de cette sauvegarde.")
	var effects: Array[String] = Incidents.active_lines(world)
	if effects.is_empty(): effects.append("Aucun effet temporaire.")
	if not world.decision.is_empty() and world.Decisions.summary(world) not in effects: effects.append(world.Decisions.summary(world))
	for section in [{"title":"Achats datés","text":"\n".join(purchase_lines)},{"title":"Effets en cours","text":"\n".join(effects)},{"title":"Actualités · plus récentes en haut","text":"\n".join(reversed_news())}]:
		var column = VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		columns.add_child(column)
		column.add_child(_label(section.title,16,ACCENT))
		var content = RichTextLabel.new()
		content.custom_minimum_size.y = 130
		content.size_flags_vertical = Control.SIZE_EXPAND_FILL
		content.focus_mode = Control.FOCUS_ALL
		content.add_theme_font_size_override("normal_font_size",18 if reading_large else 14)
		content.text = section.text
		column.add_child(content)
	var controls = HBoxContainer.new()
	body.add_child(controls)
	var back = _button("Retour [F3]",close_overview,controls)
	_button("Aide [F1]",open_help,controls)
	back.grab_focus()
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
		elif screen == "overview": close_overview()
		elif screen == "saves": close_saves()
		elif screen == "decision": show_game()
		elif tutorial != null: finish_tutorial()
		else: show_menu()
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
