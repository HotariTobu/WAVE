class_name EditorStoplightSector
extends EditorSelectable

var stoplight: EditorStoplight

var split:
	get:
		return stoplight.splits[_split_index]

var _split_index: int

var _points = PackedVector2Array()
var _selecting_color: Color
var _selected_color: Color

var _center: Vector2

func _init(_stoplight: EditorStoplight, split_index: int, radius: float, start_angle: float, end_angle: float):
	super(EditorPhysicsLayer.STOPLIGHT_SECTOR)

	stoplight = _stoplight

	_split_index = split_index

	var point_count = floori((end_angle - start_angle) * setting.stoplight_sector_delta_angle_inv)
	_points.resize(point_count)
	for point_index in range(point_count):
		var weight = float(point_index) / (point_count - 1)
		var angle = lerpf(start_angle, end_angle, weight)

		var point = _get_point(radius, angle)
		_points[point_index] = point

	var center_angle = (start_angle + end_angle) / 2
	var hue =  center_angle / TAU
	_selecting_color = Color.from_hsv(hue, 1.0, 1.0, 0.5)
	_selected_color = Color.from_hsv(hue, 1.0, 1.0, 1.0)

	_center = _get_point(radius, center_angle)

	var last_point = _points[0]
	for point_index in range(1, point_count):
		var point = _points[point_index]
		_add_segment(last_point, point)

func _draw():
	var color: Color
	if selecting:
		color = _selecting_color
	elif selected:
		color = _selected_color
	else:
		color = setting.stoplight_sector_color

	var width = setting.selection_radius / zoom_factor
	draw_polyline(_points, color, width)

func _to_string():
	return "EditorStoplightSector(Stoplight: %s, Split index: %s)" % [
		stoplight,
		_split_index,
	]

func get_center() -> Vector2:
	return _center

func _add_segment(pos1: Vector2, pos2: Vector2):
	var segment_shape = SegmentShape2D.new()
	segment_shape.a = pos1
	segment_shape.b = pos2

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = segment_shape
	add_child(collision_shape)

static func _get_point(radius: float, angle: float) -> Vector2:
	var x = sin(angle) * radius
	var y = -cos(angle) * radius
	return Vector2(x, y)
