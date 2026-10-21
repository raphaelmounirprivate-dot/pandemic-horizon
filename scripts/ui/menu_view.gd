extends RefCounted
## Title screen and the three-step "Nouvelle partie" flow: scenario, difficulty and
## options, then the start region picked on the world map. No drop-down list.
const Card = preload("res://scripts/ui/choice_card.gd")
const MapView = preload("res://scripts/ui/region_map.gd")
const STEPS = ["Scénario", "Difficulté et options", "Région de départ"]

## Controls of a previous screen are freed with it; forget them so updates never touch them.
static func clear_fields(ui) -> void:
	for field in ["objective_choice", "decision_choice", "advanced_choice", "crises_choice", "reactive_choice", "menu_objective_detail", "menu_difficulty_detail", "menu_scenario_detail", "setup_next", "setup_summary", "start_map", "start_detail"]:
		ui.set(field, null)
	ui.scenario_cards.clear()
	ui.difficulty_cards.clear()

static func data_error(ui) -> String:
	var data = JSON.parse_string(FileAccess.get_file_as_string(ui.World.DATA_PATH))
	var error = ui.World.validate_data(data)
	if error.is_empty(): error = ui.World.Scenarios.validate(catalog(ui), data, ui.World.Content.load_files())
	return error

static func big_button(ui, text: String, action: Callable, parent: Node) -> Button:
	var button = ui._button(text, action, parent)
	button.custom_minimum_size.y = 56
	button.add_theme_font_size_override("font_size", 22)
	return button

## Title screen.
static func build(ui) -> void:
	if ui.tutorial != null: ui._restore_tutorial_session()
	if ui.screen in ["game", "result", "evolution"]: ui.autosave()
	ui.screen = "menu"
	ui.paused = true
	ui.elapsed = 0.0
	clear_fields(ui)
	ui._reset_screen("Pandemic Horizon", "Un monde connecté. Des choix qui changent la trajectoire.")
	var error = data_error(ui)
	if not error.is_empty():
		ui.body.add_child(ui._label(error))
		ui._button("Quitter", func(): ui.get_tree().quit(), ui.body)
		return
	var columns = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 48)
	ui.body.add_child(columns)
	var presentation = VBoxContainer.new()
	presentation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	presentation.alignment = BoxContainer.ALIGNMENT_CENTER
	presentation.add_theme_constant_override("separation", 16)
	columns.add_child(presentation)
	var identity = HBoxContainer.new()
	identity.add_theme_constant_override("separation", 20)
	presentation.add_child(identity)
	var emblem = load("res://scripts/ui/agent_emblem.gd").new()
	emblem.custom_minimum_size = Vector2(96, 96)
	emblem.tooltip_text = "NACRE · Emblème abstrait de réseau, sans représentation biologique réelle."
	identity.add_child(emblem)
	var name_label = ui._label("NACRE\nChaque région compte.", 30)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	identity.add_child(name_label)
	var pitch = ui._label("Faites évoluer un agent fictif à travers 24 régions reliées par la terre, les airs et la mer. Achetez des compétences, déjouez la détection et touchez 90 % de la population avant que le remède soit prêt.", 18, ui.MUTED)
	pitch.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	presentation.add_child(pitch)
	var actions = VBoxContainer.new()
	actions.custom_minimum_size.x = 420
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	columns.add_child(actions)
	var first: Button = null
	if not ui.world.regions.is_empty() and ui.world.outcome.is_empty():
		first = big_button(ui, "Reprendre la partie", ui.show_game, actions)
		first.tooltip_text = "%s · Jour %d · en pause" % [ui.world.scenario.name, ui.world.day]
	var launch = big_button(ui, "Nouvelle partie", func(): ui.show_new_game(1), actions)
	if first == null: first = launch
	big_button(ui, "Tutoriel guidé", ui.start_tutorial, actions)
	big_button(ui, "Sauvegardes", ui.open_saves, actions)
	big_button(ui, "Paramètres", ui.show_settings, actions)
	big_button(ui, "Aide [F1]", ui.open_help, actions)
	big_button(ui, "Quitter", ui.request_quit, actions)
	var footer = ui._label("Simulation abstraite · Les chiffres sont des paramètres de jeu fictifs.\n" + (ui.save_notice if not ui.save_notice.is_empty() else "Sauvegardes locales disponibles depuis le menu ou la partie."), 16, ui.MUTED)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.body.add_child(footer)
	first.grab_focus()

## "Nouvelle partie" flow. Choices are applied at once and kept when moving between steps.
static func build_setup(ui, step: int) -> void:
	ui.screen = "setup"
	ui.paused = true
	ui.setup_step = clampi(step, 1, STEPS.size())
	clear_fields(ui)
	var data = catalog(ui)
	update_choices(ui, data)
	ui._reset_screen("Nouvelle partie · Étape %d / %d · %s" % [ui.setup_step, STEPS.size(), STEPS[ui.setup_step - 1]], "")
	ui.setup_summary = ui.body.get_child(1)
	var steps = HBoxContainer.new()
	steps.add_theme_constant_override("separation", 8)
	ui.body.add_child(steps)
	for i in range(STEPS.size()):
		var target = i + 1
		var pill = ui._button("%d · %s" % [target, STEPS[i]], func(): ui.show_new_game(target), steps)
		pill.toggle_mode = true
		pill.button_pressed = target == ui.setup_step
		pill.custom_minimum_size.x = 260
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			pill.add_theme_stylebox_override(state, load("res://scripts/ui/evolution_view.gd").tab_style(state, target == ui.setup_step))
		pill.tooltip_text = ("Étape en cours · " if target == ui.setup_step else "Aller à l'étape ") + STEPS[i]
	var content = VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	ui.body.add_child(content)
	match ui.setup_step:
		1: scenario_step(ui, data, content)
		2: options_step(ui, data, content)
		3: start_step(ui, content)
	var nav = HBoxContainer.new()
	ui.body.add_child(nav)
	var back = big_button(ui, "Retour" if ui.setup_step > 1 else "Retour au menu", ui.setup_back, nav)
	back.custom_minimum_size.x = 260
	var gap = Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.add_child(gap)
	ui.setup_next = big_button(ui, "Lancer la partie" if ui.setup_step == STEPS.size() else "Suivant : " + STEPS[ui.setup_step], ui.setup_forward, nav)
	ui.setup_next.custom_minimum_size.x = 360
	update_choices(ui, data)
	ui.setup_next.grab_focus()

static func scenario_step(ui, data: Dictionary, parent: Control) -> void:
	var cards = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 16)
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(cards)
	for item in data.scenarios:
		var card = Card.new()
		var id = item.id
		card.pressed.connect(func(): ui.choose_scenario(id))
		cards.add_child(card)
		ui.scenario_cards[id] = card
	ui.menu_scenario_detail = ui._label("", 16, ui.MUTED)
	ui.menu_scenario_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(ui.menu_scenario_detail)

static func options_step(ui, data: Dictionary, parent: Control) -> void:
	var cards = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 16)
	parent.add_child(cards)
	for item in data.difficulties:
		var card = Card.new()
		card.custom_minimum_size.y = 140
		var id = item.id
		card.pressed.connect(func(): ui.choose_difficulty(id))
		cards.add_child(card)
		ui.difficulty_cards[id] = card
	ui.menu_difficulty_detail = ui._label("", 15, ui.AMBER)
	parent.add_child(ui.menu_difficulty_detail)
	var columns = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 32)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(columns)
	var rules = VBoxContainer.new()
	rules.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules.add_theme_constant_override("separation", 4)
	columns.add_child(rules)
	rules.add_child(ui._label("RÈGLES DE LA PARTIE", 15, ui.MUTED))
	ui.advanced_choice = toggle("Catalogue enrichi", "Profil distinct : 18 compétences, 21 dans Dégel, événements supplémentaires.", ui.advanced_mode, rules)
	ui.advanced_choice.toggled.connect(func(enabled):
		ui.advanced_mode = enabled
		ui._update_menu_choices(ui._menu_catalog()))
	ui.crises_choice = toggle("Aléas et résilience (+3)", "Douze aléas tirés par graine et trois compétences de protection. Active le catalogue enrichi.", ui.crises_mode, rules)
	ui.crises_choice.toggled.connect(func(enabled):
		ui.crises_mode = enabled
		ui._update_menu_choices(ui._menu_catalog()))
	ui.reactive_choice = toggle("Crises réactives", "Aléas ciblant les foyers actifs, réponse à la première panne aérienne, Double relais obligatoire dans Réseaux fragiles.", ui.reactive_mode, rules)
	ui.reactive_choice.toggled.connect(func(enabled):
		ui.reactive_mode = enabled
		ui._update_menu_choices(ui._menu_catalog()))
	ui.menu_scenario_detail = ui._label("", 14, ui.MUTED)
	ui.menu_scenario_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules.add_child(ui.menu_scenario_detail)
	var goals = VBoxContainer.new()
	goals.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goals.add_theme_constant_override("separation", 4)
	columns.add_child(goals)
	goals.add_child(ui._label("OBJECTIFS ET TIRAGE", 15, ui.MUTED))
	ui.objective_choice = toggle("Objectif facultatif", "", not ui.objective_id.is_empty(), goals)
	ui.objective_choice.toggled.connect(func(enabled):
		ui.objective_id = ui.World.Objectives.for_scenario(ui.scenario_id).get("id", "") if enabled else ""
		ui._update_menu_choices(ui._menu_catalog()))
	ui.decision_choice = toggle("Décision logistique (J28)", "Événement facultatif de Dégel : options, coûts et effets présentés au jour 28.", ui.decision_enabled, goals)
	ui.decision_choice.toggled.connect(func(enabled):
		ui.decision_enabled = enabled
		ui._update_menu_choices(ui._menu_catalog()))
	ui.menu_objective_detail = ui._label("", 14, ui.MUTED)
	ui.menu_objective_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goals.add_child(ui.menu_objective_detail)
	var agent_row = HBoxContainer.new()
	agent_row.add_theme_constant_override("separation", 4)
	goals.add_child(agent_row)
	for id in ["", "nacre", "pulse", "veil"]:
		var title = "Historique" if id.is_empty() else {"nacre":"NACRE", "pulse":"ONDE", "veil":"VOILE"}[id]
		var button = ui._button(title, func():
			ui.agent_id = id
			if not id.is_empty():
				ui.reactive_mode = false
				ui.decision_enabled = false
				ui.advanced_mode = true
				ui.crises_mode = true
			ui.show_new_game(2)
		, agent_row)
		button.toggle_mode = true
		button.button_pressed = ui.agent_id == id
		button.add_theme_font_size_override("font_size", 13)
		button.add_theme_stylebox_override("normal", ui.theme.get_stylebox("normal", "Button"))
	var agent_text = "Profil stratégique expérimental · Sélectionner un agent active aléas et catalogue enrichi."
	if not ui.agent_id.is_empty():
		agent_text = ui.World.Strategy.rules().agents[ui.agent_id].description + " Décision J20 puis tous les 12 jours, selon la situation du monde ; 6 s/jour à ×1."
		ui.reactive_choice.disabled = true
		ui.decision_choice.disabled = true
	var agent_detail = ui._label(agent_text, 13, ui.ACCENT)
	agent_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goals.add_child(agent_detail)
	var seed_row = HBoxContainer.new()
	goals.add_child(seed_row)
	seed_row.add_child(ui._label("Graine", 16, ui.MUTED))
	var seed_input = SpinBox.new()
	seed_input.name = "seed_input"
	seed_input.min_value = 0
	seed_input.max_value = 999999999
	seed_input.step = 1
	seed_input.value = ui.simulation_seed
	seed_input.custom_minimum_size = Vector2(160, 44)
	seed_input.tooltip_text = "Même graine et mêmes choix : même tirage des aléas. Recommencer conserve cette graine."
	seed_input.value_changed.connect(func(value):
		ui.simulation_seed = int(value)
		if ui.setup_summary != null: ui.setup_summary.text = setup_summary(ui))
	seed_row.add_child(seed_input)
	ui._button("Autre graine", func(): seed_input.value = abs((str(Time.get_unix_time_from_system()) + str(Time.get_ticks_usec())).hash()) % 1000000000, seed_row)

static func toggle(text: String, tooltip: String, pressed: bool, parent: Control) -> CheckButton:
	var choice = CheckButton.new()
	choice.text = text
	choice.tooltip_text = tooltip
	choice.custom_minimum_size.y = 44
	choice.button_pressed = pressed
	parent.add_child(choice)
	return choice

static func start_step(ui, parent: Control) -> void:
	var row = HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 24)
	parent.add_child(row)
	var preview = ui.World.new()
	var error = preview.start_with({"start": ui.start_id, "scenario": ui.scenario_id, "crises": ui.crises_mode or ui.scenario_id == "fragile2042"})
	if not error.is_empty(): preview.start_with({"start": "boreale"})
	var map = MapView.new()
	map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map.setup(preview)
	map.motion_enabled = false
	map.show_status_banner = false
	for i in range(preview.regions.size()):
		if preview.regions[i].id == ui.start_id: map.selected = i
	map.region_selected.connect(func(index): ui.choose_start(preview.regions[index].id))
	row.add_child(map)
	ui.start_map = map
	var side = VBoxContainer.new()
	side.custom_minimum_size.x = 380
	side.add_theme_constant_override("separation", 8)
	row.add_child(side)
	ui.start_detail = ui._label("", 18)
	ui.start_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(ui.start_detail)
	refresh_start(ui)

static func refresh_start(ui) -> void:
	if ui.start_map == null: return
	var world = ui.start_map.world
	var region: Dictionary = {}
	var links = 0
	for item in world.regions:
		if item.id == ui.start_id: region = item
	for edge in world.connections:
		if ui.start_id in edge: links += 1
	var lines: Array[String] = ["Départ : " + region.get("name", ui.start_id), "Population : %d · %d liaisons" % [int(region.get("population", 0)), links]]
	if ui.start_locked: lines.append("Départ imposé par le scénario %s." % ui.world_scenario_name())
	else: lines.append("Cliquez une région de la carte, ou Tab puis Entrée, pour changer de départ.")
	lines.append("")
	lines.append(setup_summary(ui))
	ui.start_detail.text = "\n".join(lines)
	ui.start_map.refresh()

static func setup_summary(ui) -> String:
	var parts: Array[String] = [ui.world_scenario_name(), ui.difficulty_name()]
	if ui.crises_mode: parts.append("Aléas")
	elif ui.advanced_mode: parts.append("Catalogue enrichi")
	if ui.reactive_mode: parts.append("Crises réactives")
	if not ui.objective_id.is_empty(): parts.append("Objectif facultatif")
	if ui.decision_enabled: parts.append("Décision J28")
	parts.append("Graine %d" % ui.simulation_seed)
	return " · ".join(parts)

static func catalog(ui) -> Dictionary:
	return ui.World.Crises.catalog(ui.World.Scenarios.load_catalog())

## Applies the option dependencies to the model, then mirrors them on the controls of the current step.
static func update_choices(ui, catalog: Dictionary) -> void:
	if not ui.agent_id.is_empty():
		ui.advanced_mode = true
		ui.crises_mode = true
		ui.reactive_mode = false
		ui.decision_enabled = false
	if ui.reactive_mode: ui.crises_mode = true
	if ui.scenario_id == "fragile2042": ui.crises_mode = true
	if ui.crises_mode: ui.advanced_mode = true
	if ui.scenario_id != "degel2042": ui.decision_enabled = false
	var optional = ui.World.Objectives.for_scenario(ui.scenario_id)
	if ui.objective_id != optional.get("id", ""): ui.objective_id = ""
	var scenario: Dictionary = {}
	for item in catalog.scenarios:
		if item.id == ui.scenario_id: scenario = item
	ui.start_locked = scenario.get("forced_start", "") != ""
	if ui.start_locked: ui.start_id = scenario.forced_start
	if ui.crises_choice != null:
		ui.crises_choice.set_pressed_no_signal(ui.crises_mode)
		ui.crises_choice.disabled = ui.scenario_id == "fragile2042" or ui.reactive_mode
		ui.advanced_choice.set_pressed_no_signal(ui.advanced_mode)
		ui.advanced_choice.disabled = ui.crises_mode
		ui.reactive_choice.set_pressed_no_signal(ui.reactive_mode)
		if not ui.agent_id.is_empty():
			ui.reactive_choice.disabled = true
			ui.advanced_choice.disabled = true
			ui.crises_choice.disabled = true
	if ui.decision_choice != null:
		ui.decision_choice.visible = ui.scenario_id == "degel2042"
		ui.decision_choice.set_pressed_no_signal(ui.decision_enabled)
		if not ui.agent_id.is_empty(): ui.decision_choice.disabled = true
		ui.objective_choice.disabled = optional.is_empty()
		ui.objective_choice.text = "Objectif facultatif : " + optional.get("name", "indisponible")
		ui.objective_choice.set_pressed_no_signal(not ui.objective_id.is_empty())
	if ui.menu_objective_detail != null:
		ui.menu_objective_detail.text = ui.World.Objectives.description(optional)
		if ui.reactive_mode:
			ui.menu_objective_detail.text = ("" if optional.is_empty() else ui.World.Objectives.description(optional) + "\n") + "Crises réactives : choix à la première panne aérienne."
			if ui.scenario_id == "fragile2042": ui.menu_objective_detail.text += "\nObligatoire : Centrale → Méridien et Savane, 6 000 unités chacun avant J60 inclus."
	if ui.menu_scenario_detail != null and not scenario.is_empty():
		ui.menu_scenario_detail.text = profile_text(ui) if ui.setup_step == 1 else scenario.description + "\n" + profile_text(ui)
	for item in catalog.scenarios:
		if ui.scenario_cards.has(item.id):
			ui.scenario_cards[item.id].show_card(item.name, scenario_card_text(ui, item), item.id == ui.scenario_id)
	for item in catalog.difficulties:
		if ui.difficulty_cards.has(item.id):
			ui.difficulty_cards[item.id].show_card(item.name, difficulty_text(item), item.id == ui.difficulty_id)
		if item.id == ui.difficulty_id and ui.menu_difficulty_detail != null:
			ui.menu_difficulty_detail.text = "%s · Recherche ×%.2f · Seuil de détection ×%.2f · Score ×%.2f · Objectif : 90 %% avant le remède" % [item.name, item.cure_multiplier, item.detection_multiplier, item.score_multiplier]
	if ui.setup_summary != null: ui.setup_summary.text = setup_summary(ui)
	refresh_start(ui)

static func profile_text(ui) -> String:
	if not ui.agent_id.is_empty(): return ui.World.Strategy.rules().agents[ui.agent_id].name + " · Profil stratégique expérimental · Décisions récurrentes"
	var degel = ui.scenario_id == "degel2042"
	if ui.crises_mode: return "Profil aléas : %d compétences · 12 aléas + %d événements fixes, favorables ou défavorables à la diffusion." % [24 if degel else 21, 12 if degel else 14]
	if ui.advanced_mode: return "Profil enrichi : %d compétences · %d événements programmés." % [21 if degel else 18, 12 if degel else 14]
	return "Profil classique : %d compétences · règles historiques conservées." % [9 if degel else 6]

static func scenario_card_text(ui, item: Dictionary) -> String:
	var start = "Départ libre : vous choisissez la région" if item.forced_start == "" else "Départ imposé : " + ui.region_label(item.forced_start)
	var extra = ""
	if item.id == "fragile2042": extra = "\nActive automatiquement les aléas."
	return "%s\n\n%s%s" % [item.description, start, extra]

static func difficulty_text(item: Dictionary) -> String:
	var research = "Remède plus lent" if item.cure_multiplier < 1 else ("Remède plus rapide" if item.cure_multiplier > 1 else "Remède de référence")
	var detection = "détection plus tardive" if item.detection_multiplier > 1 else ("détection plus précoce" if item.detection_multiplier < 1 else "détection de référence")
	return "%s (×%.2f), %s. Score ×%.2f." % [research, item.cure_multiplier, detection, item.score_multiplier]
