extends Control
const RED = Color("ff766d")
const ACCENT = Color("69d6bd")
const AMBER = Color("efbc70")
const ANCHORS = {
 "toundra":Vector2(.105,.16),"boreale":Vector2(.25,.13),"hauts_pays":Vector2(.14,.34),"occident":Vector2(.28,.34),
 "peninsule":Vector2(.20,.51),"equateur":Vector2(.34,.50),"atlantide":Vector2(.39,.66),"plateaux":Vector2(.28,.69),"australe":Vector2(.32,.88),
 "centrale":Vector2(.48,.29),"meridien":Vector2(.58,.27),"steppes":Vector2(.69,.14),"taiga":Vector2(.83,.13),
 "levant":Vector2(.61,.45),"orient":Vector2(.80,.34),"pacifique":Vector2(.94,.33),"littoral":Vector2(.92,.52),
 "delta":Vector2(.73,.53),"jade":Vector2(.81,.68),"corail":Vector2(.95,.73),"savane":Vector2(.48,.55),
 "cap_sud":Vector2(.56,.80),"mousson":Vector2(.83,.87),"archipel":Vector2(.96,.94)}
var world: PandemicWorld
var selected = 0
var buttons: Array[Button] = []
var motion_enabled = false
var visual_time = 0.0
var polygons: Array[PackedVector2Array] = []
var land_dots: Dictionary = {}
var layout_size = Vector2.ZERO
var display_positions: Dictionary = {}
signal region_selected(index: int)
func setup(model: PandemicWorld) -> void:
	world = model
	custom_minimum_size = Vector2(640,220)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	clip_contents = true
	var geo = JSON.parse_string(FileAccess.get_file_as_string("res://assets/maps/world-land.geojson"))
	for feature in geo.features:
		var rings = feature.geometry.coordinates if feature.geometry.type == "MultiPolygon" else [feature.geometry.coordinates]
		for part in rings:
			var polygon: PackedVector2Array = []
			for point in part[0]: polygon.append(Vector2((point[0]+180.0)/360.0,(85.0-point[1])/145.0))
			polygons.append(polygon)
	for id in ANCHORS:
		land_dots[id] = []
		for dot in range(100):
			var angle = dot*2.39996
			var point: Vector2 = ANCHORS[id] + Vector2(cos(angle)*.075,sin(angle)*.16)*sqrt((dot+.5)/100.0)
			for polygon in polygons:
				if Geometry2D.is_point_in_polygon(point,polygon):
					land_dots[id].append(point)
					break
	for i in range(world.regions.size()):
		var button = Button.new()
		button.custom_minimum_size = Vector2(44,44)
		button.add_theme_font_size_override("font_size",12)
		for state in ["normal","hover","pressed","disabled"]:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0,0,0,.12 if state == "hover" else 0)
			style.set_corner_radius_all(22)
			button.add_theme_stylebox_override(state,style)
		var focus = StyleBoxFlat.new()
		focus.bg_color = Color(0,0,0,0)
		focus.border_color = ACCENT
		focus.set_border_width_all(2)
		focus.set_corner_radius_all(22)
		button.add_theme_stylebox_override("focus",focus)
		button.pressed.connect(func():
			selected = i
			region_selected.emit(i)
			refresh())
		add_child(button)
		buttons.append(button)
	resized.connect(refresh)
	refresh()
func project(point: Vector2) -> Vector2:
	return Vector2(24,25)+point*(size-Vector2(48,50))
func map_position(region: Dictionary) -> Vector2:
	return display_positions.get(region.id,project(ANCHORS.get(region.id,Vector2(region.position[0],region.position[1]))))
func refresh() -> void:
	if world == null: return
	if layout_size != size:
		layout_size = size
		for region in world.regions: display_positions[region.id] = project(ANCHORS.get(region.id,Vector2(.5,.5)))
		for iteration in range(40):
			for a in range(world.regions.size()):
				for b in range(a+1,world.regions.size()):
					var first = world.regions[a].id
					var second = world.regions[b].id
					var delta: Vector2 = display_positions[second]-display_positions[first]
					if absf(delta.x) >= 46 or absf(delta.y) >= 46: continue
					var move = Vector2.ZERO
					if 46-absf(delta.x) < 46-absf(delta.y): move.x = (46-absf(delta.x))*.51 * (1 if delta.x >= 0 else -1)
					else: move.y = (46-absf(delta.y))*.51 * (1 if delta.y >= 0 else -1)
					display_positions[first] = (display_positions[first]-move).clamp(Vector2(22,25),size-Vector2(22,22))
					display_positions[second] = (display_positions[second]+move).clamp(Vector2(22,25),size-Vector2(22,22))
	for i in range(buttons.size()):
		var region = world.regions[i]
		buttons[i].text = str(i+1)
		buttons[i].position = map_position(region)-Vector2(22,22)
		buttons[i].size = Vector2(44,44)
		buttons[i].tooltip_text = "%s · %.1f %% touchés · %d actifs\n%s" % [region.name,100.0*(region.active+region.removed)/region.population,region.active,world.transport_summary(region.id)]
	queue_redraw()
func _process(delta: float) -> void:
	if motion_enabled:
		visual_time += minf(delta,.1)
		queue_redraw()
func curve(a: Vector2,b: Vector2,t: float) -> Vector2:
	return a.lerp(b,t)+(b-a).orthogonal().normalized()*minf(a.distance_to(b)*.12,38.0)*sin(t*PI)
func visible_flows() -> Array:
	return world.latest_flows.filter(func(flow): return flow.day == world.day and world.route_is_open([flow.from,flow.to]))
func _draw() -> void:
	if world == null: return
	draw_rect(Rect2(Vector2.ZERO,size),Color("0a161d"))
	for x in range(0,13): draw_line(Vector2(size.x*x/12.0,0),Vector2(size.x*x/12.0,size.y),Color("11232c"),1)
	for y in range(1,6): draw_line(Vector2(0,size.y*y/6.0),Vector2(size.x,size.y*y/6.0),Color("11232c"),1)
	for polygon in polygons:
		var projected: PackedVector2Array = []
		for point in polygon: projected.append(project(point))
		if projected.size() >= 3:
			draw_colored_polygon(projected,Color("233b40"))
			draw_polyline(projected,Color("3d5659"),1,true)
	var positions: Dictionary = {}
	for region in world.regions: positions[region.id] = map_position(region)
	for edge in world.connections:
		var a: Vector2 = positions[edge[0]]
		var b: Vector2 = positions[edge[1]]
		var path: PackedVector2Array = []
		for j in range(21): path.append(curve(a,b,j/20.0))
		if world.route_is_open(edge): draw_polyline(path,Color(.35,.65,.69,.18),1,true)
		else:
			for j in range(0,20,2): draw_line(path[j],path[j+1],Color(.94,.74,.44,.55),1.5,true)
			var p = curve(a,b,.5)
			draw_line(p-Vector2(4,4),p+Vector2(4,4),AMBER,2,true)
			draw_line(p-Vector2(4,-4),p+Vector2(4,-4),AMBER,2,true)
	for i in range(world.regions.size()):
		var region = world.regions[i]
		var p: Vector2 = positions[region.id]
		var fraction = float(region.active+region.removed)/region.population
		if fraction > 0:
			draw_circle(p,8+sqrt(fraction)*42,Color(1,.24,.18,.09+fraction*.08))
			var dots: Array = land_dots.get(region.id,[])
			for dot in range(mini(dots.size(),3+int(fraction*dots.size()))): draw_circle(project(dots[dot]),1.6,RED)
			draw_arc(p,14+(sin(visual_time*2+i)+1)*2,0,TAU,24,Color(1,.46,.42,.55),1.2,true)
		if i == selected: draw_arc(p,20,0,TAU,32,ACCENT,2,true)
		draw_circle(p,12,Color("8f302f") if region.active > 0 else Color("20363e"))
		if i == selected: draw_string(ThemeDB.fallback_font,p+Vector2(23,4),region.name,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("e1eee9"))
	for flow in visible_flows():
		var a: Vector2 = positions[flow.from]
		var b: Vector2 = positions[flow.to]
		var t = fposmod(visual_time*.35+float(ANCHORS.keys().find(flow.from))*.113,1.0)
		var p = curve(a,b,t)
		draw_line(curve(a,b,maxf(0,t-.08)),p,RED,2,true)
		draw_circle(p,3,RED)
		var direction = (curve(a,b,minf(1,t+.02))-p).normalized()
		draw_line(p,p-direction.rotated(.6)*7,RED,1.5,true)
		draw_line(p,p-direction.rotated(-.6)*7,RED,1.5,true)
	draw_string(ThemeDB.fallback_font,Vector2(14,18),"MONDE EN CRISE · %d FOYERS ACTIFS" % world.regions.filter(func(r): return r.active > 0).size(),HORIZONTAL_ALIGNMENT_LEFT,-1,12,RED)
