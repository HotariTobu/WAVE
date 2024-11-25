class_name EditorStoplightSector
extends EditorContent

const HALF_PI = PI / 2

var _start_angle: float
var _end_angle: float
var _radius: float

var _points = PackedVector2Array()
var _selecting_color: Color
var _selected_color: Color

var _center: Vector2

var _segments: Array[CollisionShape2D]:
	get:
		return _segments
	set(next):
		var prev = _segments

		for child in prev:
			child.queue_free()

		for child in next:
			add_child(child)

		_segments = next


func _init(split: SplitData):
	super(split, EditorPhysicsLayer.STOPLIGHT_SECTOR)


func _draw():
	var point_count = len(_points)
	if point_count < 2:
		return

	var color: Color
	if selecting:
		color = _selecting_color
	elif selected:
		color = _selected_color
	else:
		color = setting.stoplight_sector_color

	var width = setting.selection_radius / zoom_factor
	draw_arc(Vector2.ZERO, _radius, _start_angle, _end_angle, point_count, color, width)


func get_local_center() -> Vector2:
	return _center


func _update_process():
	super()
	set_process(is_processing() or is_visible_in_tree())


func update(radius: float, start_angle: float, end_angle: float):
	_radius = radius
	_start_angle = start_angle - HALF_PI
	_end_angle = end_angle - HALF_PI

	var point_count = floori((end_angle - start_angle) * setting.stoplight_sector_delta_angle_inv)
	_points.resize(point_count)
	for point_index in range(point_count):
		var weight = float(point_index) / (point_count - 1)
		var angle = lerpf(start_angle, end_angle, weight)

		var point = _get_point(radius, angle)
		_points[point_index] = point

	var center_angle = (start_angle + end_angle) / 2
	var hue = center_angle / TAU
	_selecting_color = Color.from_hsv(hue, setting.stoplight_sector_saturation, 1.0, 0.5)
	_selected_color = Color.from_hsv(hue, setting.stoplight_sector_saturation, 1.0, 1.0)

	_center = _get_point(radius, center_angle)

	var segments: Array[CollisionShape2D]
	segments.resize(point_count - 1)

	for index in range(point_count - 1):
		var segment = create_segment()
		segment.shape.a = _points[index]
		segment.shape.b = _points[index + 1]
		segments[index] = segment

	_segments = segments

	queue_redraw()


static func _get_point(radius: float, angle: float) -> Vector2:
	var x = sin(angle) * radius
	var y = -cos(angle) * radius
	return Vector2(x, y)
