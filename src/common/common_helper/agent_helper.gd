class_name AgentHelper


static func draw_to(canvas: CanvasItem, head_length: float, length: float, color: Color, width: float) -> void:
	var width_half = width / 2
	var points = [
		Vector2.ZERO,
		Vector2(-head_length, width_half),
		Vector2(-length, width_half),
		Vector2(-length, -width_half),
		Vector2(-head_length, -width_half),
	]
	canvas.draw_colored_polygon(points, color)
