extends Control
func _draw() -> void:
	var center = size*.5
	draw_circle(center,7,Color("ff766d"))
	for i in range(6):
		var point = center+Vector2.from_angle(i*TAU/6)*24
		draw_line(center,point,Color("557374"),1.5,true)
		draw_circle(point,4,Color("69d6bd"))
	draw_arc(center,31,.2,TAU-.2,40,Color("a7c4c9"),1,true)
