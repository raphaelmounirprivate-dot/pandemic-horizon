extends Button
var evolution_id = ""
var family_id = ""
var selected_node = false
var blocked = false
func _draw() -> void:
	if selected_node:
		var selection = StyleBoxFlat.new()
		selection.bg_color = Color.TRANSPARENT
		selection.border_color = Color("69d6bd")
		selection.set_border_width_all(2)
		selection.set_corner_radius_all(6)
		draw_style_box(selection,Rect2(Vector2(1,1),size-Vector2(2,2)))
	if blocked:
		draw_polyline(PackedVector2Array([Vector2(size.x-9,4),Vector2(size.x-4,9),Vector2(size.x-9,14),Vector2(size.x-14,9),Vector2(size.x-9,4)]),Color("efbc70"),1,true)
	load("res://scripts/ui/family_symbol.gd").symbol(self,Vector2(14,size.y*.5),family_id,get_theme_color("font_color"))
