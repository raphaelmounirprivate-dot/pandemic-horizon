extends PanelContainer
## Result card: caption, large value, optional meter and a short explanation.
const Meter = preload("res://scripts/ui/progress_meter.gd")
var caption_label: Label
var value_label: Label
var note_label: Label
var meter: Control

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(0, 128)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("16333e")
	style.set_corner_radius_all(6)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	add_theme_stylebox_override("panel", style)
	var rows = VBoxContainer.new()
	rows.add_theme_constant_override("separation", 6)
	add_child(rows)
	caption_label = _part(15, Color("a7c4c9"))
	rows.add_child(caption_label)
	value_label = _part(34, Color("e1eee9"))
	rows.add_child(value_label)
	meter = Meter.new()
	meter.visible = false
	rows.add_child(meter)
	note_label = _part(14, Color("a7c4c9"))
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(note_label)

func _part(font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func show_stat(caption: String, value: String, note: String) -> void:
	caption_label.text = caption
	value_label.text = value
	note_label.text = note
	note_label.visible = not note.is_empty()

func show_meter(fraction: float, fill: Color, target: float = -1.0) -> void:
	meter.visible = true
	meter.show_value(fraction, fill, target)
