extends RefCounted
static func build(ui) -> void:
	if ui.tutorial != null: ui._restore_tutorial_session()
	if ui.screen == "game" or ui.screen == "result": ui.autosave()
	ui.screen = "menu"
	ui.paused = true
	ui.elapsed = 0.0
	ui._reset_screen("Pandemic Horizon", "Un monde connecté. Des choix qui changent la trajectoire.")
	var center = HBoxContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ui.body.add_child(center)
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
	identity.add_child(ui._label("NACRE\nChaque région compte.",26))
	var description = ui._label("Agent fictif dans 24 régions reliées.\nObjectif : toucher 90 % avant le remède.",18)
	presentation.add_child(description)
	ui.menu_scenario_detail = ui._label("", 16, ui.MUTED)
	ui.menu_scenario_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	presentation.add_child(ui.menu_scenario_detail)
	ui.menu_difficulty_detail = ui._label("", 16, ui.AMBER)
	presentation.add_child(ui.menu_difficulty_detail)
	ui.objective_choice = CheckButton.new()
	ui.objective_choice.text = "Objectif facultatif : Premiers relais"
	ui.objective_choice.custom_minimum_size.y = 44
	ui.objective_choice.button_pressed = not ui.objective_id.is_empty()
	ui.objective_choice.toggled.connect(func(enabled): ui.objective_id = ui.World.Objectives.for_scenario(ui.scenario_id).get("id","") if enabled else "")
	var optional_choices = HBoxContainer.new()
	presentation.add_child(optional_choices)
	ui.objective_choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	optional_choices.add_child(ui.objective_choice)
	ui.decision_choice = CheckButton.new()
	ui.decision_choice.text = "Décision logistique (J28)"
	ui.decision_choice.custom_minimum_size.y = 44
	ui.decision_choice.button_pressed = ui.decision_enabled
	ui.decision_choice.tooltip_text = "Événement facultatif Dégel : options, coûts et effets présentés au jour 28."
	ui.decision_choice.toggled.connect(func(enabled): ui.decision_enabled = enabled)
	optional_choices.add_child(ui.decision_choice)
	ui.menu_objective_detail = ui._label("", 16, ui.MUTED)
	ui.menu_objective_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	presentation.add_child(ui.menu_objective_detail)
	var profile_choices = HBoxContainer.new()
	presentation.add_child(profile_choices)
	var learning = HBoxContainer.new()
	presentation.add_child(learning)
	ui._button("Tutoriel guidé", ui.start_tutorial, learning)
	ui._button("Aide [F1]", ui.open_help, learning)
	ui.advanced_choice = CheckButton.new()
	ui.advanced_choice.text = "Catalogue enrichi"
	ui.advanced_choice.custom_minimum_size.y = 44
	ui.advanced_choice.button_pressed = ui.advanced_mode
	ui.advanced_choice.tooltip_text = "Profil distinct : 18 évolutions de base, 21 dans Dégel, événements supplémentaires. Les parties classiques gardent leurs règles."
	ui.advanced_choice.toggled.connect(func(enabled):
		ui.advanced_mode = enabled
		ui._update_menu_choices(ui._menu_catalog()))
	profile_choices.add_child(ui.advanced_choice)
	ui.crises_choice = CheckButton.new()
	ui.crises_choice.text = "Aléas et résilience (+3)"
	ui.crises_choice.custom_minimum_size.y = 44
	ui.crises_choice.button_pressed = ui.crises_mode
	ui.crises_choice.tooltip_text = "Douze aléas tirés par graine, huit types favorables/défavorables à la diffusion et trois compétences de protection. Active le catalogue enrichi."
	ui.crises_choice.toggled.connect(func(enabled):
		ui.crises_mode = enabled
		ui._update_menu_choices(ui._menu_catalog()))
	profile_choices.add_child(ui.crises_choice)
	ui.reactive_choice = CheckButton.new()
	ui.reactive_choice.text = "Crises réactives"
	ui.reactive_choice.custom_minimum_size.y = 44
	ui.reactive_choice.button_pressed = ui.reactive_mode
	ui.reactive_choice.tooltip_text = "Ciblage des foyers actifs, réponse à la première panne aérienne et Double relais obligatoire dans Réseaux fragiles. Profil de sauvegarde distinct."
	ui.reactive_choice.toggled.connect(func(enabled):
		ui.reactive_mode = enabled
		ui._update_menu_choices(ui._menu_catalog()))
	profile_choices.add_child(ui.reactive_choice)
	learning.add_child(ui._label("Graine",16,ui.MUTED))
	var seed_input = SpinBox.new()
	seed_input.name = "seed_input"
	seed_input.min_value = 0
	seed_input.max_value = 999999999
	seed_input.step = 1
	seed_input.value = ui.simulation_seed
	seed_input.custom_minimum_size = Vector2(140,44)
	seed_input.tooltip_text = "Même graine et mêmes choix : même tirage des aléas. Recommencer conserve cette graine."
	seed_input.value_changed.connect(func(value): ui.simulation_seed = int(value))
	learning.add_child(seed_input)
	ui._button("Autre",func(): seed_input.value = abs((str(Time.get_unix_time_from_system())+str(Time.get_ticks_usec())).hash()) % 1000000000,learning)
	var actions = VBoxContainer.new()
	actions.custom_minimum_size.x = 320
	center.add_child(actions)
	var data = JSON.parse_string(FileAccess.get_file_as_string(ui.World.DATA_PATH))
	var error = ui.World.validate_data(data)
	var catalog: Variant = ui._menu_catalog()
	if error.is_empty():
		error = ui.World.Scenarios.validate(catalog, data, ui.World.Content.load_files())
	if not error.is_empty():
		actions.add_child(ui._label(error))
		ui._button("Quitter", func(): ui.get_tree().quit(), actions)
		return
	actions.add_child(ui._label("Scénario", 18))
	ui.scenario_choice = OptionButton.new()
	ui.scenario_choice.custom_minimum_size.y = 44
	for i in range(catalog.scenarios.size()):
		ui.scenario_choice.add_item(catalog.scenarios[i].name)
		ui.scenario_choice.set_item_metadata(i, catalog.scenarios[i].id)
		if catalog.scenarios[i].id == ui.scenario_id: ui.scenario_choice.select(i)
	ui.scenario_choice.item_selected.connect(func(index):
		ui.scenario_id = ui.scenario_choice.get_item_metadata(index)
		ui._update_menu_choices(catalog)
	)
	actions.add_child(ui.scenario_choice)
	actions.add_child(ui._label("Difficulté", 18))
	ui.difficulty_choice = OptionButton.new()
	ui.difficulty_choice.custom_minimum_size.y = 44
	for i in range(catalog.difficulties.size()):
		ui.difficulty_choice.add_item(catalog.difficulties[i].name)
		ui.difficulty_choice.set_item_metadata(i, catalog.difficulties[i].id)
		if catalog.difficulties[i].id == ui.difficulty_id: ui.difficulty_choice.select(i)
	ui.difficulty_choice.item_selected.connect(func(index):
		ui.difficulty_id = ui.difficulty_choice.get_item_metadata(index)
		ui._update_menu_choices(catalog)
	)
	actions.add_child(ui.difficulty_choice)
	actions.add_child(ui._label("Région de départ", 18))
	var choices = OptionButton.new()
	choices.custom_minimum_size.y = 44
	ui.start_choice = choices
	for i in range(data.regions.size()):
		choices.add_item(data.regions[i].name)
		choices.set_item_metadata(i, data.regions[i].id)
		if data.regions[i].id == ui.start_id:
			choices.select(i)
	choices.item_selected.connect(func(index): ui.start_id = choices.get_item_metadata(index))
	actions.add_child(choices)
	ui._update_menu_choices(catalog)
	var launch = ui._button("Nouvelle partie", ui.start_game, actions)
	if not ui.world.regions.is_empty() and ui.world.outcome.is_empty():
		ui._button("Reprendre la partie", ui.show_game, actions)
	ui._button("Paramètres", ui.show_settings, actions)
	ui._button("Sauvegardes", ui.open_saves, actions)
	ui._button("Quitter", ui.request_quit, actions)
	var footer = ui._label("Simulation abstraite · Les chiffres sont des paramètres de jeu fictifs.\n" + (ui.save_notice if not ui.save_notice.is_empty() else "Sauvegardes locales disponibles depuis le menu ou la partie."), 16, ui.MUTED)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.body.add_child(footer)
	launch.grab_focus()

static func catalog(ui) -> Dictionary:
	return ui.World.Crises.catalog(ui.World.Scenarios.load_catalog())

static func update_choices(ui, catalog: Dictionary) -> void:
	if ui.reactive_mode: ui.crises_mode = true
	if ui.scenario_id == "fragile2042": ui.crises_mode = true
	if ui.crises_mode: ui.advanced_mode = true
	ui.crises_choice.set_pressed_no_signal(ui.crises_mode)
	ui.crises_choice.disabled = ui.scenario_id == "fragile2042" or ui.reactive_mode
	ui.advanced_choice.set_pressed_no_signal(ui.advanced_mode)
	ui.advanced_choice.disabled = ui.crises_mode
	ui.decision_choice.visible = ui.scenario_id == "degel2042"
	if ui.scenario_id != "degel2042": ui.decision_enabled = false
	ui.decision_choice.set_pressed_no_signal(ui.decision_enabled)
	var optional = ui.World.Objectives.for_scenario(ui.scenario_id)
	ui.objective_choice.disabled = optional.is_empty()
	ui.objective_choice.text = "Objectif facultatif : " + optional.get("name","indisponible")
	if ui.objective_id != optional.get("id",""):
		ui.objective_id = ""
	ui.objective_choice.set_pressed_no_signal(not ui.objective_id.is_empty())
	ui.menu_objective_detail.text = ui.World.Objectives.description(optional)
	if ui.reactive_mode:
		ui.menu_objective_detail.text = ("" if optional.is_empty() else ui.World.Objectives.description(optional)+"\n") + "Crises réactives : choix à la première panne aérienne."
		if ui.scenario_id == "fragile2042": ui.menu_objective_detail.text += "\nObligatoire : Centrale → Méridien et Savane, 6 000 unités chacun avant J60 inclus."
	for item in catalog.scenarios:
		if item.id == ui.scenario_id:
			ui.start_choice.disabled = item.forced_start != ""
			if item.forced_start != "": ui.start_id = item.forced_start
			ui.menu_scenario_detail.text = item.description
			ui.menu_scenario_detail.text += "\n" + ("Profil enrichi : %d évolutions · %d événements programmés." % [21 if ui.scenario_id == "degel2042" else 18,12 if ui.scenario_id == "degel2042" else 14] if ui.advanced_mode else "Profil classique : %d évolutions · règles historiques conservées." % [9 if ui.scenario_id == "degel2042" else 6])
			if ui.crises_mode: ui.menu_scenario_detail.text = item.description + "\nProfil aléas : %d compétences · 12 aléas + %d événements fixes.\nConséquences favorables ou défavorables à la diffusion." % [24 if ui.scenario_id == "degel2042" else 21,12 if ui.scenario_id == "degel2042" else 14]
	for i in range(ui.start_choice.item_count):
		if ui.start_choice.get_item_metadata(i) == ui.start_id: ui.start_choice.select(i)
	for item in catalog.difficulties:
		if item.id == ui.difficulty_id:
			ui.menu_difficulty_detail.text = "%s · Recherche ×%.2f · Seuil de détection ×%.2f\nScore ×%.2f · Objectif : 90 %% avant le remède" % [item.name, item.cure_multiplier, item.detection_multiplier, item.score_multiplier]
