class_name EditorStoplightSector
extends EditorContent

var _sector_helper: SectorHelper

var _selecting_color: Color
var _selected_color: Color

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
	if _sector_helper.point_count < 2:
		return

	var color: Color
	if selecting:
		_sector_helper.color = _selecting_color
	elif selected:
		_sector_helper.color = _selected_color
	else:
		_sector_helper.color = setting.stoplight_sector_inactive_color

	var width = setting.selection_radius / zoom_factor
	_sector_helper.draw_to(self, width)


func _update_process():
	super()
	set_process(is_processing() or is_visible_in_tree())


func update(sector_helper: SectorHelper):
	_sector_helper = sector_helper

	_selecting_color = Color(sector_helper.color, 0.5)
	_selected_color = sector_helper.color

	var point_count = sector_helper.point_count
	var segment_count = point_count - 1

	var points: PackedVector2Array
	points.resize(point_count)

	for point_index in range(point_count):
		var weight = float(point_index) / segment_count
		var angle = lerpf(sector_helper.start_angle, sector_helper.end_angle, weight)

		var point = Vector2.from_angle(angle) * sector_helper.radius
		points[point_index] = point

	var segments: Array[CollisionShape2D]
	segments.resize(segment_count)

	for index in range(segment_count):
		var segment = create_segment()
		segment.shape.a = points[index]
		segment.shape.b = points[index + 1]
		segments[index] = segment

	_segments = segments

	queue_redraw()
