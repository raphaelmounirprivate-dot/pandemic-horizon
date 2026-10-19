extends Control
## Horizontal meter with an optional target tick. The value is always also written in a label next to it.
var value = 0.0
var color = Color("69d6bd")
var target = -1.0

func _init() -> void:
	custom_minimum_size = Vector2(0, 12)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_value(fraction: float, fill: Color, target_fraction: float = -1.0) -> void:
	value = clampf(fraction, 0.0, 1.0)
	color = fill
	target = target_fraction
	queue_redraw()

func _draw() -> void:
	var track = StyleBoxFlat.new()
	track.bg_color = Color("0a161d")
	track.set_corner_radius_all(4)
	draw_style_box(track, Rect2(Vector2.ZERO, size))
	if value > 0.0:
		var fill = StyleBoxFlat.new()
		fill.bg_color = color
		fill.set_corner_radius_all(4)
		draw_style_box(fill, Rect2(Vector2.ZERO, Vector2(maxf(size.x * value, 8.0), size.y)))
	if target >= 0.0:
		var x = size.x * target
		draw_line(Vector2(x, -4), Vector2(x, size.y + 4), Color("e1eee9"), 2)
