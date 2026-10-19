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
