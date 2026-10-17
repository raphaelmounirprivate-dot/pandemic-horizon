extends Button
var evolution_id = ""
var selected_node = false
func _draw() -> void:
	if selected_node:
		var selection = StyleBoxFlat.new()
		selection.bg_color = Color.TRANSPARENT
		selection.border_color = Color("69d6bd")
		selection.set_border_width_all(2)
		selection.set_corner_radius_all(6)
		draw_style_box(selection,Rect2(Vector2(1,1),size-Vector2(2,2)))
	var center = Vector2(14,size.y*.5)
	var color = get_theme_color("font_color")
	if evolution_id in ["mobility","seasonal","air_bridge","sea_logistics","land_network"]:
		for offset in [Vector2(7,-6),Vector2(7,6),Vector2(-6,0)]:
			draw_line(center,center+offset,color,1.4,true)
			draw_circle(center+offset,2,color)
	elif evolution_id in ["discretion","resilience"]:
		draw_polyline(PackedVector2Array([center+Vector2(-6,-6),center+Vector2(6,-6),center+Vector2(6,1),center+Vector2(0,7),center+Vector2(-6,1),center+Vector2(-6,-6)]),color,1.4,true)
	else:
		draw_circle(center,3,color)
		for angle in range(6):
			var direction = Vector2.from_angle(angle*TAU/6)
			draw_line(center+direction*5,center+direction*8,color,1.4,true)
