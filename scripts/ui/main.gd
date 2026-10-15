extends Control

const World = preload("res://scripts/simulation/world.gd")
const MapView = preload("res://scripts/ui/region_map.gd")
const INK = Color("e1eee9")
const MUTED = Color("a7c4c9")
const ACCENT = Color("69d6bd")
const CONFIG_PATH = "user://settings.cfg"

var world = World.new()
var screen: String = "menu"
var paused: bool = true
var speed: int = 1
var elapsed: float = 0.0
var start_id: String = "boreale"
var selected: int = 0
var body: VBoxContainer
var metrics: Label
var region_details: Label
var journal_label: Label
var status_label: Label
var pause_button: Button
var map_view: Control
var evolution_buttons: Dictionary = {}

func _ready() -> void:
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
	if screen != "game" or world.totals().active != 200:
		get_tree().quit(1)
		return
	world.points = 100
	buy_evolution("transmission")
	buy_evolution("mobility")
	buy_evolution("discretion")
	toggle_pause()
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
	show_settings()
	show_menu()
	if screen != "menu":
		get_tree().quit(1)
		return
	print("RUNTIME_SMOKE_OK: exported data, purchases, victory, defeat, restart, settings, menu")
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
	heading.add_child(_label("PROTOTYPE 0.1", 16, MUTED))
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
	var description = _label("Pilotez un agent fictif dans six régions reliées.\nFaites évoluer sa diffusion et surveillez le remède.\n\nObjectif : toucher 90 % de la population\navant l'achèvement du remède.", 22)
	presentation.add_child(description)
	presentation.add_child(_label("Standard · Difficulté normale · Partie hors ligne\nDégel 2042 et sauvegardes prévus pour les prochains lots.", 16, MUTED))
	var actions = VBoxContainer.new()
	actions.custom_minimum_size.x = 320
	center.add_child(actions)
	actions.add_child(_label("Région de départ", 20))
	var choices = OptionButton.new()
	choices.custom_minimum_size.y = 48
	var data = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH))
	var error = World.validate_data(data)
	if not error.is_empty():
		actions.add_child(_label(error))
		_button("Quitter", func(): get_tree().quit(), actions)
		return
	for i in range(data.regions.size()):
		choices.add_item(data.regions[i].name)
		choices.set_item_metadata(i, data.regions[i].id)
		if data.regions[i].id == start_id:
			choices.select(i)
	choices.item_selected.connect(func(index): start_id = choices.get_item_metadata(index))
	actions.add_child(choices)
	var launch = _button("Nouvelle partie", start_game, actions)
	if not world.regions.is_empty() and world.outcome.is_empty():
		_button("Reprendre la partie", show_game, actions)
	_button("Paramètres", show_settings, actions)
	_button("Quitter", func(): get_tree().quit(), actions)
	body.add_child(_label("Simulation abstraite · Les chiffres sont des paramètres de jeu fictifs.\nAucune sauvegarde de partie : quitter l'application perd la progression.", 16, MUTED))
	launch.grab_focus()

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
	body.add_child(_label("Clavier\nEspace : pause / reprise\n1, 2, 4 : vitesse de simulation\nÉchap : retour au menu, partie mise en pause\nTab et Maj + Tab : navigation · Entrée : activer", 22))
	status_label = _label("Le prototype ne contient pas encore de son ni d'animations décoratives.", 18, MUTED)
	body.add_child(status_label)
	_button("Retour au menu", show_menu, body)
	fullscreen.grab_focus()

func start_game() -> void:
	var error = world.start(start_id)
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

func show_game() -> void:
	screen = "game"
	_reset_screen("Pandemic Horizon", "Standard · Objectif : 90 % touchés · Défaite si remède à 100 % ou disparition des cas actifs.")
	metrics = _label("", 22, ACCENT)
	body.add_child(metrics)
	var content = HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(content)
	var map_column = VBoxContainer.new()
	map_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(map_column)
	map_view = MapView.new()
	map_view.setup(world)
	map_view.selected = selected
	map_view.region_selected.connect(func(index):
		selected = index
		_refresh()
	)
	map_column.add_child(map_view)
	map_column.add_child(_label("Carte schématique · Traits : connexions · Barres : cumul touché", 16, MUTED))
	var sidebar = VBoxContainer.new()
	sidebar.add_theme_constant_override("separation", 6)
	sidebar.custom_minimum_size.x = 330
	content.add_child(sidebar)
	region_details = _label("", 16)
	sidebar.add_child(region_details)
	sidebar.add_child(_label("Évolutions", 22))
	for id in World.EVOLUTIONS:
		var evolution = World.EVOLUTIONS[id]
		var button = _button("", func(): buy_evolution(id), sidebar)
		button.tooltip_text = evolution.effect
		evolution_buttons[id] = button
		sidebar.add_child(_label(evolution.effect, 14, MUTED))
	status_label = _label("", 16, MUTED)
	body.add_child(status_label)
	journal_label = _label("", 16, MUTED)
	journal_label.custom_minimum_size.y = 44
	body.add_child(journal_label)
	var controls = HBoxContainer.new()
	body.add_child(controls)
	pause_button = _button("", toggle_pause, controls)
	for value in [1, 2, 4]:
		_button("×%d" % value, func():
			speed = value
			_refresh()
		, controls)
	_button("Recommencer", start_game, controls)
	_button("Menu", show_menu, controls)
	_refresh()
	pause_button.grab_focus()

func buy_evolution(id: String) -> void:
	var error = world.purchase(id)
	_refresh()
	if not error.is_empty():
		status_label.text = error

func toggle_pause() -> void:
	paused = not paused
	elapsed = 0.0
	_refresh()

func _refresh() -> void:
	if screen != "game":
		return
	metrics.text = "Jour %d     Touchés : %.1f %%     Remède : %.1f %%     Points : %d" % [world.day, world.coverage() * 100, world.cure, world.points]
	var region = world.regions[selected]
	region_details.text = "%s · Population : %d\nSains : %d · Actifs : %d\nRetirés : %d" % [region.name, region.population, region.healthy, region.active, region.removed]
	for id in evolution_buttons:
		var evolution = World.EVOLUTIONS[id]
		var acquired = id in world.purchased
		evolution_buttons[id].text = "%s · %s" % [evolution.name, "acquise" if acquired else "%d pts" % evolution.cost]
		# Keep insufficient purchases focusable so keyboard users can read the reason.
		evolution_buttons[id].disabled = acquired
		evolution_buttons[id].tooltip_text = evolution.effect + (" Points insuffisants." if world.points < evolution.cost else "")
	pause_button.text = "Reprendre [Espace]" if paused else "Pause [Espace]"
	status_label.text = "En pause · Prenez le temps de choisir vos évolutions." if paused else "Simulation en cours · Vitesse ×%d" % speed
	journal_label.text = "\n".join(world.journal.slice(maxi(0, world.journal.size() - 2)))
	map_view.refresh()

func _process(delta: float) -> void:
	advance_time(delta)

func advance_time(delta: float) -> void:
	if screen != "game" or paused or not world.outcome.is_empty():
		return
	elapsed += delta * speed
	# Bound work per frame while preserving the accumulated time.
	var steps = 0
	while elapsed >= 0.5 and steps < 16:
		elapsed -= 0.5
		world.step()
		steps += 1
		if not world.outcome.is_empty():
			paused = true
			show_result()
			return
	_refresh()

func show_result() -> void:
	screen = "result"
	paused = true
	_reset_screen("Objectif atteint" if world.outcome == "victory" else "Fin de partie", world.outcome_text())
	body.add_child(_label("Jour %d\nPopulation touchée : %.1f %%\nRemède : %.1f %%\nScore : %d" % [world.day, world.coverage() * 100, world.cure, world.score()], 28))
	body.add_child(_label("Score = couverture × 10 000 − jours × 10, avec un minimum de zéro.", 16, MUTED))
	var log = RichTextLabel.new()
	log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log.text = "\n".join(world.journal)
	body.add_child(log)
	var restart = _button("Rejouer avec le même départ", start_game, body)
	_button("Choisir une autre région", show_menu, body)
	restart.grab_focus()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		show_menu()
		get_viewport().set_input_as_handled()
	elif screen == "game":
		if event.keycode == KEY_SPACE:
			toggle_pause()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_1, KEY_2, KEY_4]:
			speed = {KEY_1: 1, KEY_2: 2, KEY_4: 4}[event.keycode]
			_refresh()
