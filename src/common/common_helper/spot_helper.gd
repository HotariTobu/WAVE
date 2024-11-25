class_name SpotHelper

enum Shape {CIRCLE, TRIANGLE, SQUARE}

static func draw_to(canvas: CanvasItem, color: Color, radius: float, shape: Shape) -> void:
	match shape:
		Shape.CIRCLE:
			canvas.draw_circle(Vector2.ZERO, radius, color)
		Shape.TRIANGLE:
			canvas.draw_colored_polygon(_get_polygon_points(3, radius), color)
		Shape.SQUARE:
			canvas.draw_colored_polygon(_get_polygon_points(4, radius), color)

static func _get_polygon_points(point_count: int, radius: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	points.resize(point_count)

	for index in range(point_count):
		var angle = TAU * index / point_count
		var x = radius * sin(angle)
		var y = radius * cos(angle)
		points[index] = Vector2(x, y)

	return points
