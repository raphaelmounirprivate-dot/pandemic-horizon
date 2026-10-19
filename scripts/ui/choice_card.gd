extends Button
## Large selectable card (scenario, difficulty). The chosen card is outlined and says so in words.
const ACCENT = Color("69d6bd")
const MUTED = Color("a7c4c9")
var chosen = false
var title_label: Label
var body_label: Label
var state_label: Label

func _init() -> void:
	clip_contents = true
	custom_minimum_size = Vector2(0, 150)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)
	var rows = VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_theme_constant_override("separation", 6)
	margin.add_child(rows)
	title_label = _part(24, Color("e1eee9"))
	rows.add_child(title_label)
	body_label = _part(15, MUTED)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(body_label)
	state_label = _part(15, ACCENT)
	rows.add_child(state_label)

func _part(font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func show_card(title: String, body: String, is_chosen: bool) -> void:
	title_label.text = title
	body_label.text = body
	chosen = is_chosen
	state_label.text = "Choisi" if chosen else "Choisir"
	state_label.add_theme_color_override("font_color", ACCENT if chosen else MUTED)
	tooltip_text = title + "\n" + body
	queue_redraw()

func _draw() -> void:
	if not chosen: return
	var outline = StyleBoxFlat.new()
	outline.bg_color = Color.TRANSPARENT
	outline.border_color = ACCENT
	outline.set_border_width_all(3)
	outline.set_corner_radius_all(6)
	draw_style_box(outline, Rect2(Vector2(1, 1), size - Vector2(2, 2)))
