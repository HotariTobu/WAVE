class_name EditorLanePoint
extends EditorSelectable

enum Type {START, WAY, END}

var lane: EditorLane
var type = Type.WAY

func _init(_lane: EditorLane, index: int):
	super(EditorPhysicsLayer.LANE_POINT)

	lane = _lane

	if index == 0:
		type = Type.START
	elif index == lane.curve.point_count - 1:
		type = Type.END

	position = lane.curve.get_point_position(index)

	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 0

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle_shape
	add_child(collision_shape)

func _draw():
	var color: Color
	if selecting:
		match type:
			Type.START:
				color = setting.lane_start_point_selecting_color
			Type.WAY:
				color = setting.lane_way_point_selecting_color
			Type.END:
				color = setting.lane_end_point_selecting_color
	elif selected:
		match type:
			Type.START:
				color = setting.lane_start_point_selected_color
			Type.WAY:
				color = setting.lane_way_point_selected_color
			Type.END:
				color = setting.lane_end_point_selected_color
	else:
		return

	var radius = setting.selection_radius / zoom_factor
	draw_circle(Vector2.ZERO, radius, color)

func _to_string():
	return "EditorLanePoint(Type: %s, Pos: %s)" % [
		Type.find_key(type),
		position,
	]
