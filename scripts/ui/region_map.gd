extends Control

const LAND = Color("193a45")
const ACCENT = Color("69d6bd")
var world: PandemicWorld
var selected: int = 0
var buttons: Array[Button] = []
signal region_selected(index: int)

func setup(model: PandemicWorld) -> void:
	world = model
	custom_minimum_size = Vector2(720, 260)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	for i in range(world.regions.size()):
		var button = Button.new()
		button.custom_minimum_size = Vector2(112, 44)
		button.add_theme_font_size_override("font_size", 14)
		button.pressed.connect(func():
			selected = i
			region_selected.emit(i)
			refresh()
		)
		add_child(button)
		buttons.append(button)
	resized.connect(refresh)
	refresh()

func map_position(region: Dictionary) -> Vector2:
	return Vector2(62, 30) + Vector2(region.position[0], region.position[1]) * (size - Vector2(124, 60))

func refresh() -> void:
	if world == null:
		return
	for i in range(buttons.size()):
		var region = world.regions[i]
		buttons[i].text = region.name
		buttons[i].position = map_position(region) - Vector2(56, 22)
		buttons[i].size = Vector2(112, 44)
		buttons[i].modulate = ACCENT if i == selected else Color.WHITE
		buttons[i].tooltip_text = "%s : %d cas actifs. Entrée pour sélectionner." % [region.name, region.active]
	queue_redraw()

func _draw() -> void:
	if world == null:
		return
	draw_style_box(_background(), Rect2(Vector2.ZERO, size))
	for y in range(28, int(size.y), 40):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color("122d37"), 1.0)
	for x in range(24, int(size.x), 60):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color("122d37"), 1.0)
	var positions: Dictionary = {}
	for region in world.regions:
		positions[region.id] = map_position(region)
	for edge in world.connections:
		var open = world.route_is_open(edge)
		if open:
			draw_line(positions[edge[0]], positions[edge[1]], Color("3e6e7c"), 2.0, true)
		else:
			draw_dashed_line(positions[edge[0]], positions[edge[1]], Color("efbc70"), 3.0, 8.0, true)
	for i in range(world.regions.size()):
		var region = world.regions[i]
		var p = map_position(region)
		var polygon = PackedVector2Array([
			p + Vector2(-59, -25), p + Vector2(48, -25), p + Vector2(59, -14),
			p + Vector2(59, 25), p + Vector2(-48, 25), p + Vector2(-59, 14)
		])
		draw_colored_polygon(polygon, LAND)
		var fraction = float(region.active + region.removed) / region.population
		draw_rect(Rect2(p + Vector2(-48, 24), Vector2(96, 3)), Color("294b55"))
		draw_rect(Rect2(p + Vector2(-48, 24), Vector2(96 * fraction, 3)), ACCENT)
	# Draw closure markers above the land so short routes remain identifiable.
	for edge in world.connections:
		if not world.route_is_open(edge):
			var middle = (positions[edge[0]] + positions[edge[1]]) * 0.5
			draw_circle(middle, 10, Color("0b2029"))
			draw_line(middle + Vector2(-6, -6), middle + Vector2(6, 6), Color("efbc70"), 3.0)
			draw_line(middle + Vector2(-6, 6), middle + Vector2(6, -6), Color("efbc70"), 3.0)

func _background() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("0b2029")
	style.set_corner_radius_all(8)
	return style
