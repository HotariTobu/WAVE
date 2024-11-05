class_name EditorLaneSegments
extends EditorSelectable

var lane: EditorLane

var _center: Vector2

func _init(_lane: EditorLane):
	super(EditorPhysicsLayer.LANE_SEGMENTS)

	lane = _lane

	var length = lane.curve.get_baked_length()
	_center = lane.curve.sample_baked(length / 2)

func _draw():
	var color: Color
	if selecting:
		color = setting.lane_selecting_color
	elif selected:
		color = setting.lane_selected_color
	else:
		return

	var points = lane.curve.get_baked_points()
	var width = setting.selection_radius / zoom_factor
	var radius = width / 2
	draw_circle(points[0], radius, color)
	draw_polyline(points, color, width)
	draw_circle(points[-1], radius, color)

func _to_string():
	return "EditorLaneSegments(Lane: %s)" % lane

func get_center() -> Vector2:
	return _center

func add_segment(pos1: Vector2, pos2: Vector2):
	var segment_shape = SegmentShape2D.new()
	segment_shape.a = pos1
	segment_shape.b = pos2

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = segment_shape
	add_child(collision_shape)
