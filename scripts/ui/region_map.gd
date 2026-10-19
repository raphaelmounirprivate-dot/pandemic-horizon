extends Control
signal region_selected(index: int)
const RED = Color("ff766d")
const ACCENT = Color("69d6bd")
const AMBER = Color("efbc70")
const Incidents = preload("res://scripts/ui/incident_view.gd")
const ANCHORS = {
 "toundra":Vector2(.105,.16),"boreale":Vector2(.25,.13),"hauts_pays":Vector2(.14,.34),"occident":Vector2(.28,.34),
 "peninsule":Vector2(.20,.51),"equateur":Vector2(.34,.50),"atlantide":Vector2(.39,.66),"plateaux":Vector2(.28,.69),"australe":Vector2(.32,.88),
 "centrale":Vector2(.48,.29),"meridien":Vector2(.58,.27),"steppes":Vector2(.69,.14),"taiga":Vector2(.83,.13),
 "levant":Vector2(.61,.45),"orient":Vector2(.80,.34),"pacifique":Vector2(.94,.33),"littoral":Vector2(.92,.52),
 "delta":Vector2(.73,.53),"jade":Vector2(.81,.68),"corail":Vector2(.95,.73),"savane":Vector2(.48,.55),
 "cap_sud":Vector2(.56,.80),"mousson":Vector2(.83,.87),"archipel":Vector2(.96,.94)}
var focused_incident = ""
var world: PandemicWorld
var selected = 0
var buttons: Array[Button] = []
var motion_enabled = false
var visual_time = 0.0
var polygons: Array[PackedVector2Array] = []
var land_dots: Dictionary = {}
var layout_size = Vector2.ZERO
var display_positions: Dictionary = {}
var zoom = 1.0
var pan = Vector2.ZERO
var dragging = false
var camera_tools: HBoxContainer
var zoom_out: Button
var zoom_in: Button
var flow_filter = "all"
var filter_button: Button
var terrain_mesh: ArrayMesh
var projected_coasts: Array[PackedVector2Array] = []
var terrain_view: Array = []
func setup(model: PandemicWorld) -> void:
	world = model
	custom_minimum_size = Vector2(640,220)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	tooltip_text = "Molette : zoom · Glisser au bouton droit ou central : déplacer\nClavier sur la carte : + / −, flèches, Origine : vue mondiale"
	var geo = JSON.parse_string(FileAccess.get_file_as_string("res://assets/maps/world-land.geojson"))
	for feature in geo.features:
		var rings = feature.geometry.coordinates if feature.geometry.type == "MultiPolygon" else [feature.geometry.coordinates]
		for part in rings:
			var polygon: PackedVector2Array = []
			for point in part[0]: polygon.append(Vector2((point[0]+180.0)/360.0,(85.0-point[1])/145.0))
			polygons.append(polygon)
	build_terrain()
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
			focused_incident = ""
			selected = i
			region_selected.emit(i)
			refresh())
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		button.focus_entered.connect(func(): reveal_region(i))
		add_child(button)
		buttons.append(button)
	camera_tools = HBoxContainer.new()
	camera_tools.add_theme_constant_override("separation",4)
	add_child(camera_tools)
	zoom_out = camera_button("−",func(): zoom_at(size*.5,zoom/1.25))
	zoom_in = camera_button("+",func(): zoom_at(size*.5,zoom*1.25))
	camera_button("Vue mondiale",reset_view)
	filter_button = camera_button("Flux : tous",cycle_filter)
	resized.connect(refresh)
	refresh()
func camera_button(title: String, action: Callable) -> Button:
	var button = Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(44,44)
	button.add_theme_font_size_override("font_size",13)
	button.pressed.connect(action)
	camera_tools.add_child(button)
	return button
func cycle_filter() -> void:
	var filters = ["all","land","air","sea"]
	set_flow_filter(filters[(filters.find(flow_filter)+1)%filters.size()])
func set_flow_filter(value: String) -> void:
	flow_filter = value if value in ["all","land","air","sea"] else "all"
	filter_button.text = "Flux : " + {"all":"tous","land":"terre","air":"air","sea":"mer"}[flow_filter]
	filter_button.tooltip_text = "Filtrer les mouvements : tous, terre, air, mer. Les fermetures restent visibles."
	refresh()
func build_terrain() -> void:
	var vertices: PackedVector3Array = []
	var colors: PackedColorArray = []
	var indices: PackedInt32Array = []
	for polygon in polygons:
		var triangles = Geometry2D.triangulate_polygon(polygon)
		if triangles.is_empty(): continue
		var offset = vertices.size()
		for point in polygon:
			vertices.append(Vector3(point.x,point.y,0))
			var latitude = absf(85-point.y*145)
			var color = Color("263f3b").lerp(Color("41443c"),maxf(0,1-absf(latitude-27)/20)*.7)
			colors.append(color.lerp(Color("90aaa9"),smoothstep(52,78,latitude)*.75))
		for index in triangles: indices.append(index+offset)
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	terrain_mesh = ArrayMesh.new()
	terrain_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
func update_coasts() -> void:
	var view = [size,zoom,pan]
	if view == terrain_view: return
	terrain_view = view
	projected_coasts.clear()
	for polygon in polygons:
		var projected: PackedVector2Array = []
		for point in polygon: projected.append(project(point))
		projected_coasts.append(projected)
func clamp_pan() -> void:
	pan = pan.clamp(size*(1.0-zoom),Vector2.ZERO)
func zoom_at(point: Vector2, value: float) -> void:
	var next_zoom = clampf(value,1.0,4.0)
	pan = point-(point-pan)/zoom*next_zoom
	zoom = next_zoom
	clamp_pan()
	refresh()
func reset_view() -> void:
	zoom = 1.0
	pan = Vector2.ZERO
	dragging = false
	refresh()
func camera_state() -> Dictionary:
	return {"zoom":zoom,"center":(size*.5-pan)/zoom/size,"filter":flow_filter,"incident":focused_incident}
func restore_camera(state: Dictionary) -> void:
	if state.is_empty(): return
	zoom = clampf(state.zoom,1.0,4.0)
	pan = size*.5-state.center*size*zoom
	set_flow_filter(state.get("filter","all"))
	focused_incident = state.get("incident","")
	clamp_pan()
	refresh()
func move_camera(offset: Vector2) -> void:
	pan += offset
	clamp_pan()
	refresh()
func reveal_region(index: int) -> void:
	if zoom <= 1.0: return
	var point = map_position(world.regions[index])
	var safe = Rect2(Vector2(24,60),size-Vector2(48,84))
	if not safe.has_point(point): move_camera(size*.5-point)
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			for entry in Incidents.entries(world):
				if entry.scope == "route" and event.position.distance_to(incident_position(entry)) <= 16:
					focus_incident(entry.id)
					accept_event()
					return
		elif event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			zoom_at(event.position,zoom*(1.25 if event.button_index == MOUSE_BUTTON_WHEEL_UP else .8))
			accept_event()
		elif event.button_index in [MOUSE_BUTTON_RIGHT,MOUSE_BUTTON_MIDDLE]:
			dragging = event.pressed
			if dragging: grab_focus()
			accept_event()
	elif event is InputEventMouseMotion and dragging:
		move_camera(event.relative)
		accept_event()
	elif event is InputEventKey and event.pressed:
		if event.keycode in [KEY_PLUS,KEY_EQUAL,KEY_KP_ADD]: zoom_at(size*.5,zoom*1.25)
		elif event.keycode in [KEY_MINUS,KEY_KP_SUBTRACT]: zoom_at(size*.5,zoom*.8)
		elif event.keycode == KEY_HOME: reset_view()
		elif event.keycode in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]:
			move_camera({KEY_LEFT:Vector2(64,0),KEY_RIGHT:Vector2(-64,0),KEY_UP:Vector2(0,64),KEY_DOWN:Vector2(0,-64)}[event.keycode])
		else: return
		accept_event()
func _notification(what: int) -> void:
	if what in [NOTIFICATION_WM_WINDOW_FOCUS_OUT,NOTIFICATION_EXIT_TREE]: dragging = false
func project(point: Vector2) -> Vector2:
	return (Vector2(24,25)+point*(size-Vector2(48,50)))*zoom+pan
func map_position(region: Dictionary) -> Vector2:
	return display_positions.get(region.id,Vector2.ZERO)*zoom+pan
func refresh() -> void:
	if world == null: return
	if layout_size != size:
		if layout_size.x > 0 and layout_size.y > 0:
			var center = (layout_size*.5-pan)/zoom/layout_size
			pan = size*.5-center*size*zoom
		layout_size = size
		clamp_pan()
		for region in world.regions: display_positions[region.id] = Vector2(24,25)+ANCHORS.get(region.id,Vector2(.5,.5))*(size-Vector2(48,50))
		for iteration in range(40):
			# Keep the fixed camera toolbar clear in the initial world view.
			var tools_width = camera_tools.get_combined_minimum_size().x if is_instance_valid(camera_tools) else 215.0
			for id in display_positions:
				var point: Vector2 = display_positions[id]
				if point.x > size.x-tools_width-30 and point.y < 72:
					display_positions[id].y = 72
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
		for entry in Incidents.entries(world):
			if (entry.scope == "region" and entry.target == region.id) or (entry.scope == "route" and region.id in entry.target): buttons[i].tooltip_text += "\n"+entry.text
	if is_instance_valid(camera_tools):
		camera_tools.size = camera_tools.get_combined_minimum_size()
		camera_tools.position = Vector2(size.x-camera_tools.size.x-8,4)
		zoom_out.disabled = zoom <= 1.0
		zoom_in.disabled = zoom >= 4.0
	update_coasts()
	queue_redraw()
func incident_position(entry: Dictionary) -> Vector2:
	if entry.scope == "region": return display_positions[entry.target]*zoom+pan+Vector2(16,-16)
	if entry.scope == "route": return curve(display_positions[entry.target[0]]*zoom+pan,display_positions[entry.target[1]]*zoom+pan,0.5)
	return Vector2(-1000,-1000)
func focus_incident(id: String) -> bool:
	for entry in Incidents.entries(world):
		if entry.id != id or entry.scope == "global": continue
		var region_id = entry.target if entry.scope == "region" else entry.target[0]
		for i in range(world.regions.size()):
			if world.regions[i].id == region_id: selected = i
		zoom = maxf(zoom,1.8)
		pan += size*.5-incident_position(entry)
		clamp_pan()
		focused_incident = id
		refresh()
		grab_focus()
		region_selected.emit(selected)
		return true
	return false
func focus_next_incident() -> bool:
	var local = Incidents.entries(world).filter(func(e): return e.scope != "global")
	if local.is_empty(): return false
	var current = -1
	for i in range(local.size()):
		if local[i].id == focused_incident: current = i
	return focus_incident(local[(current+1)%local.size()].id)
func _get_tooltip(at_position: Vector2) -> String:
	for entry in Incidents.entries(world):
		if entry.scope != "global" and at_position.distance_to(incident_position(entry)) <= 16: return entry.text
	return tooltip_text
func draw_incidents() -> void:
	for entry in Incidents.entries(world):
		if entry.scope == "global": continue
		var point = incident_position(entry)
		var color = ACCENT if entry.impact == "favorable" else AMBER
		draw_circle(point,12,Color("091519"))
		draw_arc(point,11,0,TAU,24,ACCENT if entry.id == focused_incident else color,2,true)
		if entry.id == focused_incident: draw_arc(point,14,0,TAU,28,Color("e1eee9"),1.5,true)
		match entry.template:
			"storm":
				draw_arc(point+Vector2(-2,-2),5,PI*.15,PI*1.8,16,color,1.5,true)
				draw_polyline(PackedVector2Array([point+Vector2(2,0),point+Vector2(-2,4),point+Vector2(2,4),point+Vector2(-1,8)]),color,1.5,true)
			"earthquake":
				draw_polyline(PackedVector2Array([point+Vector2(-8,1),point+Vector2(-4,1),point+Vector2(-1,-6),point+Vector2(2,6),point+Vector2(5,0),point+Vector2(8,0)]),color,1.5,true)
			_:
				draw_line(point+Vector2(-6,0),point+Vector2(6,0),color,2,true)
				draw_line(point+Vector2(0,-6),point+Vector2(0,6),color,2,true)
func _process(delta: float) -> void:
	if motion_enabled:
		visual_time += minf(delta,.1)
		queue_redraw()
func curve(a: Vector2,b: Vector2,t: float) -> Vector2:
	return a.lerp(b,t)+(b-a).orthogonal().normalized()*minf(a.distance_to(b)*.12,38.0)*sin(t*PI)
func visible_flows() -> Array:
	return world.latest_flows.filter(func(flow): return flow.day == world.day and world.route_is_open([flow.from,flow.to]) and (flow_filter == "all" or flow.mode == flow_filter))
func transport_icon(mode: String, center: Vector2, angle: float, scale_value: float, color: Color) -> void:
	var outline: PackedVector2Array
	match mode:
		"air": outline = PackedVector2Array([Vector2(-7,-1),Vector2(-1,-1),Vector2(2,-7),Vector2(4,-7),Vector2(2,-1),Vector2(8,0),Vector2(2,1),Vector2(4,7),Vector2(2,7),Vector2(-1,1),Vector2(-7,1),Vector2(-5,0),Vector2(-7,-1)])
		"sea": outline = PackedVector2Array([Vector2(-6,-4),Vector2(3,-4),Vector2(8,0),Vector2(3,4),Vector2(-6,4),Vector2(-6,-4),Vector2(-2,-4),Vector2(-2,-1),Vector2(2,-1),Vector2(2,-4)])
		_: outline = PackedVector2Array([Vector2(-7,-3),Vector2(3,-3),Vector2(3,-1),Vector2(7,-1),Vector2(7,3),Vector2(-7,3),Vector2(-7,-3)])
	var transformed: PackedVector2Array = []
	for point in outline: transformed.append(center+point.rotated(angle)*scale_value)
	draw_polyline(transformed,color,1.4,true)
	if mode == "land":
		draw_circle(center+Vector2(-4,4).rotated(angle)*scale_value,1.5*scale_value,color)
		draw_circle(center+Vector2(4,4).rotated(angle)*scale_value,1.5*scale_value,color)
func _draw() -> void:
	if world == null: return
	draw_rect(Rect2(Vector2.ZERO,size),Color("0a161d"))
	for x in range(0,13): draw_line(Vector2(size.x*x/12.0,0),Vector2(size.x*x/12.0,size.y),Color("11232c"),1)
	for y in range(1,6): draw_line(Vector2(0,size.y*y/6.0),Vector2(size.x,size.y*y/6.0),Color("11232c"),1)
	draw_set_transform_matrix(Transform2D(Vector2((size.x-48)*zoom,0),Vector2(0,(size.y-50)*zoom),Vector2(24,25)*zoom+pan))
	draw_mesh(terrain_mesh,null)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	for projected in projected_coasts:
		if projected.size() >= 3: draw_polyline(projected,Color("557374"),1,true)
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
		for mode in ["air","sea"]:
			if world.connections.any(func(edge): return region.id in edge and world.route_mode(edge) == mode):
				transport_icon(mode,p+Vector2(-13 if mode == "air" else 13,15),0,.55,Color("a7c4c9"))
	for flow in visible_flows():
		var a: Vector2 = positions[flow.from]
		var b: Vector2 = positions[flow.to]
		var t = fposmod(visual_time*.35+float(ANCHORS.keys().find(flow.from))*.113,1.0)
		var p = curve(a,b,t)
		draw_line(curve(a,b,maxf(0,t-.08)),p,RED,2,true)
		draw_circle(p,3,RED)
		var direction = (curve(a,b,minf(1,t+.02))-p).normalized()
		transport_icon(flow.mode,p,direction.angle(),1.0,RED)
	draw_incidents()
	draw_string(ThemeDB.fallback_font,Vector2(14,18),"MONDE EN CRISE · %d FOYERS ACTIFS" % world.regions.filter(func(r): return r.active > 0).size(),HORIZONTAL_ALIGNMENT_LEFT,-1,12,RED)
