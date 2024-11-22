class_name Lane


static func draw_to(canvas: CanvasItem, points: PackedVector2Array, color: Color, width: float) -> void:
	var point_count = len(points)

	assert(point_count >= 2)

	var half_width = width / 2

	for index in range(point_count - 1):
		var from = points[index]
		var to = points[index + 1]
		var side = from.direction_to(to).orthogonal() * half_width
		var segment_points = [from + side, from - side, to]
		canvas.draw_colored_polygon(segment_points, color)
