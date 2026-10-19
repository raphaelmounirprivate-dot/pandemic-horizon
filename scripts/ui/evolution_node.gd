extends Button
## Skill node: family symbol, full name, cost and a written state (never colour alone).
const ACCENT = Color("69d6bd")
const AMBER = Color("efbc70")
var evolution_id = ""
var family_id = ""
var selected_node = false
var blocked = false
var acquired = false
var name_label: Label
var state_label: Label

func _init() -> void:
	clip_contents = true
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left",34)
	margin.add_theme_constant_override("margin_right",10)
	margin.add_theme_constant_override("margin_top",4)
	margin.add_theme_constant_override("margin_bottom",4)
	add_child(margin)
	var rows = VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.alignment = BoxContainer.ALIGNMENT_CENTER
	rows.add_theme_constant_override("separation",0)
	margin.add_child(rows)
	name_label = _part(15)
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	rows.add_child(name_label)
	state_label = _part(13)
	state_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	rows.add_child(state_label)

func _part(font_size: int) -> Label:
	var label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size",font_size)
	return label

func show_state(title: String, cost_text: String, state: String, ok: bool) -> void:
	name_label.text = title
	state_label.text = state if cost_text.is_empty() else cost_text + " · " + state
	state_label.add_theme_color_override("font_color",ACCENT if ok else AMBER)
	queue_redraw()

func _draw() -> void:
	if acquired:
		var done = StyleBoxFlat.new()
		done.bg_color = Color.TRANSPARENT
		done.border_color = ACCENT
		done.set_border_width_all(1)
		done.set_corner_radius_all(6)
		draw_style_box(done,Rect2(Vector2.ZERO,size))
	if selected_node:
		var selection = StyleBoxFlat.new()
		selection.bg_color = Color.TRANSPARENT
		selection.border_color = ACCENT
		selection.set_border_width_all(3)
		selection.set_corner_radius_all(6)
		draw_style_box(selection,Rect2(Vector2(1,1),size-Vector2(2,2)))
	if blocked:
		draw_polyline(PackedVector2Array([Vector2(size.x-9,4),Vector2(size.x-4,9),Vector2(size.x-9,14),Vector2(size.x-14,9),Vector2(size.x-9,4)]),AMBER,1,true)
	var center = Vector2(17,size.y*.5)
	load("res://scripts/ui/family_symbol.gd").symbol(self,center,family_id,ACCENT if acquired else get_theme_color("font_color"))
