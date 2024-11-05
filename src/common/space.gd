class_name Space
extends Path2D

var color: Color
var width: float

var block_sources: Array
var block_targets: Array[Space]

var is_closed: bool

func _draw():
	if curve.point_count < 2:
		return

	var points = curve.get_baked_points()
	draw_polyline(points, color, width)

func _to_string():
	return "Space(Start: %s, End: %s, Count: %s)" % [
		curve.get_point_position(0),
		curve.get_point_position(curve.point_count - 1),
		curve.point_count,
	]

func to_dict() -> Dictionary:
	var points = []
	points.resize(curve.point_count)

	for index in range(len(points)):
		var point = curve.get_point_position(index)
		points[index] = point

	var space_to_index = func(space: Space):
		return space.get_index()

	return {
		'points': points,
		'block_target_indices': block_targets.map(space_to_index),
	}

func from_dict(dict: Dictionary):
	var points = dict.get('points', [])
	curve = Curve2D.new()

	for point in points:
		curve.add_point(point)

	var block_target_indices = dict.get('block_target_indices', [])
	var len_block_targets = len(block_target_indices)

	block_targets = []
	block_targets.resize(len_block_targets)

	var container = get_parent()
	for index in range(len_block_targets):
		var space_index = block_target_indices[index]
		var space = container.get_child(space_index)
		block_targets[index] = space
		space.block_sources.append(self)
