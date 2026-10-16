extends Control

const World = preload("res://scripts/simulation/world.gd")
const MapView = preload("res://scripts/ui/region_map.gd")
const SaveStore = preload("res://scripts/persistence/save_store.gd")
const Tutorial = preload("res://scripts/ui/tutorial.gd")
const Help = preload("res://scripts/ui/help.gd")
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
var decision_choice: CheckButton
var decision_buttons: Dictionary = {}
var decision_notice: Label
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
	help_text.add_theme_font_size_override("normal_font_size", 20)
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

func reveal_evolution_group(group: Control) -> void:
	# Wrapped labels and containers need their final layout before scrolling.
	var tree = get_tree()
	await tree.process_frame
	if not is_instance_valid(group) or not group.is_inside_tree(): return
	await tree.process_frame
	if not is_instance_valid(group) or not group.is_inside_tree(): return
	if group.get_child(0).has_focus() and not mouse_press_active:
		group.get_parent().get_parent().ensure_control_visible(group)

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
	if tutorial != null and tutorial.stage == 5 and tutorial.saved_slot == slot: tutorial.ready = true
	selected = result.selected
	speed = result.speed
	start_id = world.start_region_id
	scenario_id = world.scenario.id
	difficulty_id = world.difficulty.id
	if tutorial == null: objective_id = world.objective.get("id", "")
	if tutorial == null: decision_enabled = not world.decision.is_empty()
	paused = true
	elapsed = 0.0
	save_notice = result.get("warning", "Partie chargée en pause.")
	if world.outcome.is_empty(): show_game()
	else: show_result()

func show_saves() -> void:
	paused = true
	elapsed = 0.0
	screen = "saves"
	_reset_screen("Sauvegardes d'entraînement" if tutorial != null else "Sauvegardes", "Fichiers d'essai séparés : aucune sauvegarde du joueur n'est modifiée." if tutorial != null else "Sauvegardes 0.11 · Parties 0.7 à 0.10 compatibles, sans nouvel événement rétroactif.")
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
	var settings = ConfigFile.new()
	if settings.load(CONFIG_PATH) == OK and settings.get_value("display", "fullscreen", false) == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
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
	if not optional_loaded.error.is_empty() or optional_loaded.world.points != 17:
		get_tree().quit(1)
		return
	for i in range(13): optional_loaded.world.step()
	if optional_loaded.world.decision.status != "expired":
		get_tree().quit(1)
		return
	print("RUNTIME_SMOKE_OK: standard victory/defeat, Degel phases and routes, climatic upgrades, difficulties, persistence replay, six tutorial lessons, contextual help, optional objectives and arctic flows, logistics decision cost/replay/expiration, restart, settings, menu")
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
	for child in get_children():
		remove_child(child)
		child.queue_free()
	evolution_buttons.clear()
	evolution_reasons.clear()
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	body = VBoxContainer.new()
	margin.add_child(body)
	var heading = HBoxContainer.new()
	body.add_child(heading)
	var title_label = _label(title, 30)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title_label)
	heading.add_child(_label("PROTOTYPE 0.11", 16, MUTED))
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
	spacer.custom_minimum_size.y = 40
	presentation.add_child(spacer)
	presentation.add_child(_label("Chaque région compte.", 36))
	var description = _label("Pilotez un agent fictif dans 24 régions reliées.\nFaites évoluer sa diffusion et surveillez le remède.\n\nObjectif : toucher 90 % de la population\navant l'achèvement du remède.", 22)
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
	var learning = HBoxContainer.new()
	presentation.add_child(learning)
	_button("Tutoriel guidé", start_tutorial, learning)
	_button("Aide [F1]", open_help, learning)
	var actions = VBoxContainer.new()
	actions.custom_minimum_size.x = 320
	center.add_child(actions)
	var data = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH))
	var error = World.validate_data(data)
	var catalog: Variant = World.Scenarios.load_catalog()
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

func _update_menu_choices(catalog: Dictionary) -> void:
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
	for item in catalog.scenarios:
		if item.id == scenario_id:
			start_choice.disabled = item.forced_start != ""
			if item.forced_start != "": start_id = item.forced_start
			menu_scenario_detail.text = item.description
	for i in range(start_choice.item_count):
		if start_choice.get_item_metadata(i) == start_id: start_choice.select(i)
	for item in catalog.difficulties:
		if item.id == difficulty_id:
			menu_difficulty_detail.text = "%s · Recherche ×%.2f · Seuil de détection ×%.2f\nScore ×%.2f · Objectif : 90 %% avant le remède" % [item.name, item.cure_multiplier, item.detection_multiplier, item.score_multiplier]

func show_settings() -> void:
	screen = "settings"
	paused = true
	_reset_screen("Paramètres", "Les préférences d'affichage sont conservées sur ce PC.")
	var fullscreen = CheckButton.new()
	fullscreen.text = "Plein écran"
	fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen.custom_minimum_size.y = 48
	fullscreen.toggled.connect(func(enabled):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
		var config = ConfigFile.new()
		config.set_value("display", "fullscreen", enabled)
		var error = config.save(CONFIG_PATH)
		if error != OK:
			status_label.text = "Préférence appliquée, mais impossible de l'enregistrer sur ce PC."
	)
	body.add_child(fullscreen)
	body.add_child(_label("Clavier\nEspace : pause / reprise\n1, 2, 4 : vitesse de simulation\nF1 : aide contextuelle\nÉchap : retour au menu, partie mise en pause\nTab et Maj + Tab : navigation · Entrée : activer", 22))
	status_label = _label("Le prototype ne contient pas encore de son ni d'animations décoratives.", 18, MUTED)
	body.add_child(status_label)
	_button("Retour au menu", show_menu, body)
	fullscreen.grab_focus()

func start_game() -> void:
	var error = world.start(start_id, 2042, null, null, scenario_id, difficulty_id, null, null, objective_id,decision_enabled)
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
	start_game()

func show_game() -> void:
	screen = "game"
	_reset_screen("Tutoriel guidé" if tutorial != null else "Pandemic Horizon", "Entraînement séparé · Six exercices courts · Quitter à tout moment sans perdre votre partie." if tutorial != null else "%s · %s · Objectif : 90 %% avant le remède · Défaite si extinction." % [world.scenario.name, world.difficulty.name])
	metrics = _label("", 22, ACCENT)
	body.add_child(metrics)
	objective_details = _label("", 14, MUTED)
	objective_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_details.visible = not world.objective.is_empty()
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
	map_column.add_child(_label("Terre : trait · Air : tirets · Mer : points · Fermée : croix ambre", 16, MUTED))
	effects_label = RichTextLabel.new()
	effects_label.custom_minimum_size.y = 86
	effects_label.add_theme_font_size_override("normal_font_size", 15)
	effects_label.add_theme_color_override("default_color", AMBER)
	map_column.add_child(effects_label)
	var sidebar_scroll = ScrollContainer.new()
	sidebar_scroll.custom_minimum_size.x = 360
	sidebar_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sidebar_scroll.follow_focus = true
	content.add_child(sidebar_scroll)
	var sidebar = VBoxContainer.new()
	sidebar.add_theme_constant_override("separation", 4)
	sidebar.custom_minimum_size.x = 340
	sidebar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_scroll.add_child(sidebar)
	region_details = _label("", 16)
	sidebar.add_child(region_details)
	transport_details = _label("", 14, MUTED)
	transport_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar.add_child(transport_details)
	sidebar.add_child(_label("Évolutions", 22))
	specialization_details = _label("", 14, AMBER)
	specialization_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar.add_child(specialization_details)
	for id in world.evolutions:
		var evolution = world.evolutions[id]
		var group = VBoxContainer.new()
		group.add_theme_constant_override("separation", 4)
		sidebar.add_child(group)
		var button = _button("", func(): buy_evolution(id), group)
		button.focus_entered.connect(func(): reveal_evolution_group(group))
		button.tooltip_text = evolution.effect
		evolution_buttons[id] = button
		var effect_label = _label(evolution.effect, 14, MUTED)
		effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		group.add_child(effect_label)
		var reason = _label("", 14, AMBER)
		reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		group.add_child(reason)
		evolution_reasons[id] = reason
	status_label = _label("", 16, MUTED)
	body.add_child(status_label)
	journal_label = _label("", 16, MUTED)
	journal_label.custom_minimum_size.y = 44
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
		if not world.decision.is_empty(): _button("Décision [F2]",show_decision,controls)
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
	if tutorial != null and error.is_empty(): tutorial.ready = true
	_refresh()
	if not error.is_empty():
		status_label.text = error
	if evolution_buttons.has(id) and evolution_buttons[id].has_focus():
		var group = evolution_buttons[id].get_parent()
		reveal_evolution_group(group)

func show_decision() -> void:
	if tutorial != null or world.decision.is_empty(): return
	screen = "decision"
	paused = true
	elapsed = 0.0
	_reset_screen("Logistique sous tension",World.Decisions.summary(world))
	decision_buttons.clear()
	var info = _label("Jour %d · %d points disponibles\nUn seul choix, irréversible. Les effets commencent le lendemain et se combinent avec les événements ; une route fermée le reste." % [world.day,world.points],18,MUTED)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(info)
	if World.Decisions.pending(world):
		for choice in World.Decisions.definition().choices:
			var id = choice.id
			decision_buttons[id] = _button("%s · %d pts" % [choice.name,choice.cost],func():
				var error = World.Decisions.choose(world,id)
				if error.is_empty():
					autosave()
					show_game()
				else: decision_notice.text = error
			,body)
			var detail = _label(choice.description,18,MUTED)
			detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			body.add_child(detail)
			var reason = World.Decisions.reason(world,id)
			if not reason.is_empty(): body.add_child(_label(reason,16,AMBER))
		body.add_child(_label("Sans décision avant le jour 31 : maintien de la situation, sans coût ni effet supplémentaire.",16,AMBER))
	decision_notice = _label("",16,AMBER)
	body.add_child(decision_notice)
	var space = Control.new()
	space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(space)
	var back = _button("Revenir à la partie en pause",show_game,body)
	_button("Aide [F1]",open_help,body)
	back.grab_focus()

func toggle_pause() -> void:
	if tutorial != null and not tutorial.can_run(): return
	paused = not paused
	elapsed = 0.0
	_refresh()

func _refresh() -> void:
	if screen != "game":
		return
	metrics.text = "Jour %d     Touchés : %.1f %%     Remède : %.1f %%     Points : %d     Détectées : %d/%d" % [world.day, world.coverage() * 100, world.cure, world.points, world.detected_count(), world.regions.size()]
	objective_details.text = World.Objectives.summary(world)
	var region = world.regions[selected]
	region_details.text = "%s · Population : %d\nSains : %d · Actifs : %d\nRetirés : %d · %s" % [region.name, region.population, region.healthy, region.active, region.removed, "Détectée" if region.detected else "Non détectée"]
	if world.scenario.id != "standard":
		region_details.text += "\nClimat local : croissance ×%.2f" % world.climate_factor(region.id)
	transport_details.text = world.transport_summary(region.id) + " · Détail : F1 → Transports"
	var specialization = world.specialization_id()
	specialization_details.text = "Après Mobilité : une seule spécialisation au choix." if specialization.is_empty() else "Spécialisation : " + world.evolutions[specialization].name
	for id in evolution_buttons:
		var evolution = world.evolutions[id]
		var acquired = id in world.purchased
		evolution_buttons[id].text = "%s · %s" % [evolution.name, "acquise" if acquired else "%d pts" % evolution.cost]
		# Keep insufficient purchases focusable so keyboard users can read the reason.
		evolution_buttons[id].disabled = acquired or (tutorial != null and (tutorial.stage != 2 or id != "transmission"))
		var reason = world.purchase_reason(id)
		if tutorial != null and not acquired and (tutorial.stage != 2 or id != "transmission"):
			reason = "Hors exercice" + (" · " + reason if not reason.is_empty() else "")
		evolution_buttons[id].tooltip_text = evolution.effect + " " + reason
		evolution_reasons[id].text = "Acquise" if acquired else ("Disponible" if reason.is_empty() else reason)
		evolution_reasons[id].add_theme_color_override("font_color", ACCENT if acquired or reason.is_empty() else AMBER)
	pause_button.text = "Reprendre [Espace]" if paused else "Pause [Espace]"
	status_label.text = ("En pause" if paused else "Simulation en cours") + " · Vitesse ×%d" % speed
	if not save_notice.is_empty(): status_label.text += " · " + save_notice
	status_label.clip_text = true
	journal_label.text = "\n".join(world.journal.slice(maxi(0, world.journal.size() - 2)))
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
	var lines = world.active_event_lines()
	var climate = "Phase %s · %.0f °C fictifs · Remède de phase ×%.2f\n" % [world.phase.name, world.phase.temperature, world.phase.cure_multiplier] if world.scenario.id != "standard" else ""
	effects_label.text = climate + "Événements actifs\n" + ("Aucun effet temporaire." if lines.is_empty() else "\n".join(lines))
	map_view.refresh()

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
		world.step()
		if world.day % 10 == 0 or not world.outcome.is_empty(): autosave()
		steps += 1
		if tutorial != null and tutorial.after_step(world):
			paused = true
			elapsed = 0.0
			break
		if not world.outcome.is_empty():
			paused = true
			show_result()
			return
		if World.Decisions.pending(world) and world.day == World.Decisions.definition().start_day:
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
	log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log.text = "\n".join(world.journal)
	body.add_child(log)
	var restart = _button("Rejouer avec les mêmes choix", restart_game, body)
	_button("Choisir une autre région", show_menu, body)
	_button("Sauvegardes", open_saves, body)
	_button("Aide [F1]", open_help, body)
	restart.grab_focus()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_press_active = event.pressed
	if is_instance_valid(pending_dialog) and pending_dialog.visible: return
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		if screen == "help": close_help()
		elif screen == "saves": close_saves()
		elif screen == "decision": show_game()
		elif tutorial != null: finish_tutorial()
		else: show_menu()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F1:
		open_help()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F2 and screen == "game" and not world.decision.is_empty():
		show_decision()
		get_viewport().set_input_as_handled()
	elif screen == "game":
		if event.keycode == KEY_SPACE:
			toggle_pause()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_1, KEY_2, KEY_4]:
			speed = {KEY_1: 1, KEY_2: 2, KEY_4: 4}[event.keycode]
			_refresh()
