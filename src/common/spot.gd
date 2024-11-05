class_name Spot
extends Node2D

enum Shape {CIRCLE, TRIANGLE, SQUARE}

var color: Color
var radius: float
var shape: Shape

func _draw():
	match shape:
		Shape.CIRCLE:
			draw_circle(Vector2.ZERO, radius, color)
		Shape.TRIANGLE:
			draw_colored_polygon(_get_polygon_points(3), color)
		Shape.SQUARE:
			draw_colored_polygon(_get_polygon_points(4), color)

func _to_string():
	return "Spot(Pos: %s, Shape: %s)" % [
		position,
		Shape.find_key(shape),
	]


func to_dict() -> Dictionary:
	return {
		'pos': position,
	}

func from_dict(dict: Dictionary):
	position = dict.get('pos', Vector2.INF)


func _get_polygon_points(point_count: int):
	var points = PackedVector2Array()
	points.resize(point_count)

	for index in range(point_count):
		var angle = TAU * index / point_count
		var x = radius * sin(angle)
		var y = radius * cos(angle)
		points[index] = Vector2(x, y)

	return points
