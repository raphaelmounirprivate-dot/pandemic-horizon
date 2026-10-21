extends RefCounted
## F1 help screen. Topics are a grid of buttons (no drop-down list); the current
## topic is marked in words ("●" and "Sujet affiché") and not by color alone.
const Help = preload("res://scripts/ui/help.gd")
const COLUMNS = 5

static func build(ui) -> void:
	ui.screen = "help"
	ui.paused = true
	ui.elapsed = 0.0
	ui._reset_screen("Aide", "Consultez un sujet, puis revenez à votre partie en pause. F1 ou Échap pour fermer.")
	var topics = GridContainer.new()
	topics.name = "help_topics"
	topics.columns = COLUMNS
	topics.add_theme_constant_override("h_separation", 8)
	topics.add_theme_constant_override("v_separation", 8)
	ui.body.add_child(topics)
	ui.help_buttons.clear()
	for index in range(Help.TITLES.size()):
		var button = Button.new()
		button.custom_minimum_size.y = 44
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(func(): select(ui, index))
		topics.add_child(button)
		ui.help_buttons.append(button)
	ui.help_text = RichTextLabel.new()
	ui.help_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ui.help_text.focus_mode = Control.FOCUS_ALL
	ui.help_text.add_theme_font_size_override("normal_font_size", 24 if ui.reading_large else 20)
	ui.body.add_child(ui.help_text)
	ui._button("Retour [F1]", ui.close_help, ui.body)
	select(ui, ui.help_topic)
	ui.help_buttons[ui.help_topic].grab_focus()

static func select(ui, index: int) -> void:
	ui.help_topic = clampi(index, 0, Help.TITLES.size() - 1)
	for i in range(ui.help_buttons.size()):
		var current = i == ui.help_topic
		var button: Button = ui.help_buttons[i]
		button.text = ("● " if current else "") + Help.TITLES[i]
		button.tooltip_text = Help.TITLES[i] + (" · Sujet affiché" if current else "")
		var outline = StyleBoxFlat.new()
		outline.bg_color = Color("254954") if current else Color("16333e")
		outline.border_color = ui.ACCENT
		outline.set_border_width_all(2 if current else 0)
		outline.set_corner_radius_all(6)
		outline.content_margin_left = 12
		outline.content_margin_right = 12
		outline.content_margin_top = 8
		outline.content_margin_bottom = 8
		button.add_theme_stylebox_override("normal", outline)
	ui.help_text.text = Help.text_for(ui.help_topic, ui.world, ui.selected, ui.tutorial.stage if ui.tutorial != null else -1)
