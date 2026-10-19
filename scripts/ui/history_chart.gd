extends Control
var world: RefCounted
var target_line = false # Result screen: dashed 90 % objective line.
func _draw() -> void:
	if world == null: return
	var area = Rect2(Vector2(48,22),size-Vector2(65,52))
	var font = ThemeDB.fallback_font
	for tick in range(5):
		var y = area.end.y-area.size.y*tick/4.0
		draw_line(Vector2(area.position.x,y),Vector2(area.end.x,y),Color("254954"),1)
		draw_string(font,Vector2(2,y+4),"%d %%" % (tick*25),HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("a7c4c9"))
	if target_line:
		var goal_y = area.end.y-area.size.y*0.9
		var x = area.position.x
		while x < area.end.x:
			draw_line(Vector2(x,goal_y),Vector2(minf(x+8,area.end.x),goal_y),Color("e1eee9"),1)
			x += 14
		draw_string(font,Vector2(area.position.x+8,goal_y-6),"Objectif 90 %",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e1eee9"))
	if world.history.is_empty():
		draw_string(font,area.position+Vector2(12,35),"Historique antérieur absent de cette sauvegarde.",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("a7c4c9"))
		return
	var first = int(world.history[0].day)
	var last = int(world.history[-1].day)
	for kind in ["touched","cure"]:
		var line: PackedVector2Array = []
		for sample in world.history:
			var value = float(sample.active+sample.removed)/(sample.healthy+sample.active+sample.removed) if kind == "touched" else sample.cure/10000.0
			line.append(Vector2(area.position.x+area.size.x*(sample.day-first)/maxf(1,last-first),area.end.y-area.size.y*value))
		var color = Color("ff766d") if kind == "touched" else Color("69d6bd")
		if line.size() > 1:
			if kind == "cure":
				# Draw dashes by pixel length, independent of history sampling density.
				var traveled = 0.0
				for i in range(1,line.size()):
					var length = line[i-1].distance_to(line[i])
					var offset = 0.0
					while offset < length:
						var segment = minf(length-offset,6.0-fmod(traveled,6.0))
						if segment < 0.001: segment = minf(length-offset,0.001)
						if fmod(traveled,12.0) < 6.0:
							draw_line(line[i-1].lerp(line[i],offset/length),line[i-1].lerp(line[i],(offset+segment)/length),color,2,true)
						offset += segment
						traveled += segment
			else: draw_polyline(line,color,2,true)
		elif line.size() == 1: draw_circle(line[0],3,color)
	for day in [first,last]:
		var x = area.position.x if day == first else area.end.x-60
		draw_string(font,Vector2(x,area.end.y+20),"Jour %d" % day,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("a7c4c9"))
	draw_string(font,Vector2(48,14),"Touchés : trait / Remède : tirets · depuis J%d" % first,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e1eee9"))
