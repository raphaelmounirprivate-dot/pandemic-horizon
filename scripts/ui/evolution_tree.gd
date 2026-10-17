extends GridContainer
var world: RefCounted
var nodes: Dictionary = {}
func _ready() -> void:
	resized.connect(queue_redraw)
	sort_children.connect(func(): call_deferred("queue_redraw"))
func _draw() -> void:
	if world == null: return
	for id in nodes:
		var target = nodes[id]
		for required in world.evolutions[id].requires:
			if not nodes.has(required): continue
			var source = nodes[required]
			var source_rect = source.get_global_rect()
			var target_rect = target.get_global_rect()
			source_rect.position -= global_position
			target_rect.position -= global_position
			var a: Vector2
			var b: Vector2
			var color = Color("69d6bd") if required in world.purchased else Color("a7c4c9")
			if absf(source_rect.position.y-target_rect.position.y) < 2:
				var siblings = 0
				for candidate in nodes:
					if required in world.evolutions[candidate].requires and absf(nodes[candidate].position.y-target.position.y) < 2: siblings += 1
				if siblings > 1:
					a = source_rect.position+Vector2(source_rect.size.x*.5,0)
					b = target_rect.position+Vector2(target_rect.size.x*.5,0)
					var corridor = a.y-7
					draw_polyline(PackedVector2Array([a,Vector2(a.x,corridor),Vector2(b.x,corridor),b]),color,1.4,true)
				else:
					a = source_rect.position+Vector2(source_rect.size.x,22)
					b = target_rect.position+Vector2(0,22)
					draw_line(a,b,color,1.4,true)
			else:
				a = source_rect.position+Vector2(source_rect.size.x*.5,source_rect.size.y)
				b = target_rect.position+Vector2(target_rect.size.x*.5,0)
				var middle = (a.y+b.y)*.5
				draw_polyline(PackedVector2Array([a,Vector2(a.x,middle),Vector2(b.x,middle),b]),color,1.4,true)
			draw_circle(b,2,color)
