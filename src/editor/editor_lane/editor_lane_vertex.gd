class_name EditorLaneVertex
extends EditorSelectable

enum Type { START, WAY, END }
const DEFAULT_TYPE = Type.WAY

var type = DEFAULT_TYPE

var vertex: VertexData:
	get:
		return _vertex

var _editor_global = editor_global

var _vertex: VertexData


func _init(data: VertexData):
	super(EditorPhysicsLayer.LANE_VERTEX)
	owner = get_tree().root
	name = data.id

	_vertex = data

	var source = _editor_global.source_db.get_or_add(data)
	source.bind(&"pos").to(self, &"position")
	
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
