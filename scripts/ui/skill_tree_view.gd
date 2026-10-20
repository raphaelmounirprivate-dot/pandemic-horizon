extends Control
## One family as a left-to-right tree. Columns are prerequisite depth inside the
## family; rows follow the leaves so every link is a short elbow, never a crossing.
const ACCENT = Color("69d6bd")
const MUTED = Color("a7c4c9")
const GAP_X = 40
const MIN_GAP_X = 20
const GAP_Y = 10
const MAX_NODE_WIDTH = 250
const MAX_NODE_HEIGHT = 64
var world: RefCounted
var ids: Array = []
var nodes: Dictionary = {}
var cells: Dictionary = {}
var columns = 1
var rows = 1

func setup(model: RefCounted, family_ids: Array) -> void:
	world = model
	ids = family_ids
	cells = layout(world, ids)
	columns = 1
	rows = 1
	for id in cells:
		columns = maxi(columns, int(cells[id].x) + 1)
		rows = maxi(rows, int(ceil(cells[id].y)) + 1)
	resized.connect(place_nodes)

func add_node(id: String, node: Control) -> void:
	nodes[id] = node
	add_child(node)

## Pure layout, testable without a scene: id -> Vector2(column, row).
static func layout(model: RefCounted, family_ids: Array) -> Dictionary:
	var children: Dictionary = {}
	var roots: Array = []
	for id in family_ids:
		children[id] = []
	for id in family_ids:
		var parents = model.evolutions[id].requires.filter(func(r): return r in family_ids)
		if parents.is_empty(): roots.append(id)
		else: children[parents[0]].append(id)
	var result: Dictionary = {}
	var next_row = [0.0]
	var place = func(id: String, depth: int, recurse: Callable) -> float:
		var row: float
		if children[id].is_empty():
			row = next_row[0]
			next_row[0] += 1.0
		else:
			var first = INF
			var last = -INF
			for child in children[id]:
				var child_row = recurse.call(child, depth + 1, recurse)
				first = minf(first, child_row)
				last = maxf(last, child_row)
			row = (first + last) * 0.5
		result[id] = Vector2(depth, row)
		return row
	for root in roots:
		place.call(root, 0, place)
	return result

func gap_x() -> float:
	return GAP_X if size.x >= 1100 else MIN_GAP_X

func node_size() -> Vector2:
	var width = minf(MAX_NODE_WIDTH, (size.x - gap_x() * (columns - 1)) / columns)
	var height = clampf((size.y - GAP_Y * (rows - 1)) / rows, 44, MAX_NODE_HEIGHT)
	return Vector2(floor(width), floor(height))

func place_nodes() -> void:
	var cell = node_size()
	var used = Vector2(cell.x * columns + gap_x() * (columns - 1), cell.y * rows + GAP_Y * (rows - 1))
	var origin = ((size - used) * 0.5).max(Vector2.ZERO)
	for id in nodes:
		var position_in_grid: Vector2 = cells[id]
		nodes[id].position = origin + Vector2(position_in_grid.x * (cell.x + gap_x()), position_in_grid.y * (cell.y + GAP_Y))
		nodes[id].size = cell
	queue_redraw()

func _draw() -> void:
	if world == null: return
	for id in nodes:
		for required in world.evolutions[id].requires:
			if not nodes.has(required): continue
			var source: Rect2 = nodes[required].get_rect()
			var target: Rect2 = nodes[id].get_rect()
			var a = Vector2(source.end.x, source.get_center().y)
			var b = Vector2(target.position.x, target.get_center().y)
			var middle = a.x + (b.x - a.x) * 0.5
			var done = required in world.purchased
			var color = ACCENT if done else MUTED
			draw_polyline(PackedVector2Array([a, Vector2(middle, a.y), Vector2(middle, b.y), b]), color, 3.0 if done else 1.5, true)
			draw_circle(b, 3, color)
