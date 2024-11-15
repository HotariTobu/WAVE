class_name EditorLaneVertex
extends EditorContent

enum Type { START, WAY, END }
const DEFAULT_TYPE = Type.WAY

var type = DEFAULT_TYPE


func _init(vertex: VertexData):
	super(vertex, EditorPhysicsLayer.LANE_VERTEX)
	
	add_child(create_point())

func _ready():
	super()
	
	_source.bind(&"pos").to(self, &"position")

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
