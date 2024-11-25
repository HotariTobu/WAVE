class_name EditorStoplightSector
extends EditorContent

var _radius: float
var _start_angle: float
var _end_angle: float
var _point_count: int
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
	if _point_count < 2:
		return

	var color: Color
	if selecting:
		color = _selecting_color
	elif selected:
		color = _selected_color
	else:
		color = setting.stoplight_sector_color

	var width = setting.selection_radius / zoom_factor
	draw_arc(Vector2.ZERO, _radius, _start_angle, _end_angle, _point_count, color, width)


func get_local_center() -> Vector2:
	return _center


func _update_process():
	super()
	set_process(is_processing() or is_visible_in_tree())


func update(radius: float, start_angle: float, end_angle: float):
	_radius = radius
	_start_angle = start_angle
	_end_angle = end_angle

	var angle_difference = end_angle - start_angle

	_point_count = floori(angle_difference * setting.stoplight_sector_delta_angle_inv)
	var points: PackedVector2Array
	points.resize(_point_count)
	for point_index in range(_point_count):
		var weight = float(point_index) / (_point_count - 1)
		var angle = lerpf(start_angle, end_angle, weight)

		var point = Vector2.from_angle(angle) * radius
		points[point_index] = point

	var hue = start_angle / TAU
	_selecting_color = Color.from_hsv(hue, setting.stoplight_sector_saturation, 1.0, 0.5)
	_selected_color = Color.from_hsv(hue, setting.stoplight_sector_saturation, 1.0, 1.0)

	var center_angle = angle_difference / 2
	_center = Vector2.from_angle(center_angle) * radius

	var segments: Array[CollisionShape2D]
	segments.resize(_point_count - 1)

	for index in range(_point_count - 1):
		var segment = create_segment()
		segment.shape.a = points[index]
		segment.shape.b = points[index + 1]
		segments[index] = segment

	_segments = segments

	queue_redraw()
