extends Control
var family_id = ""
static func symbol(canvas: CanvasItem, center: Vector2, family: String, color: Color) -> void:
	if family == "diffusion":
		for offset in [Vector2(7,-6),Vector2(7,6),Vector2(-6,0)]:
			canvas.draw_line(center,center+offset,color,1.4,true)
			canvas.draw_circle(center+offset,2,color)
	elif family == "discretion":
		canvas.draw_polyline(PackedVector2Array([center+Vector2(-6,-6),center+Vector2(6,-6),center+Vector2(6,1),center+Vector2(0,7),center+Vector2(-6,1),center+Vector2(-6,-6)]),color,1.4,true)
	else:
		canvas.draw_arc(center,7,0,TAU,24,color,1.4,true)
		canvas.draw_line(center+Vector2(-3,0),center+Vector2(3,0),color,1.4,true)
		canvas.draw_line(center+Vector2(0,-3),center+Vector2(0,3),color,1.4,true)
func _draw() -> void:
	symbol(self,size*.5,family_id,Color("a7c4c9"))
static func legend(ui, parent: Control) -> void:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation",12)
	parent.add_child(row)
	for group in ui.Skills.catalog():
		var item = HBoxContainer.new()
		row.add_child(item)
		var icon = load("res://scripts/ui/family_symbol.gd").new()
		icon.family_id = group.id
		icon.custom_minimum_size = Vector2(20,20)
		item.add_child(icon)
		item.add_child(ui._label(group.name,16))
