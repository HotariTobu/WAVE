class_name Lane


static func draw_to(canvas: CanvasItem, points: PackedVector2Array, color: Color, width: float) -> void:
	var point_count = len(points)

	assert(point_count >= 2)

	var half_width = width / 2

	for index in range(point_count - 1):
		var from = points[index]
		var to = points[index + 1]
		
		var normal = from.direction_to(to).orthogonal()
		
		var from_side = normal * width
		var to_side = normal * half_width
		
		var segment_points = [
			from + from_side,
			from - from_side,
			to - to_side,
			to + to_side,
		]
		
		canvas.draw_colored_polygon(segment_points, color)
