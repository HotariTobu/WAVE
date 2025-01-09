class_name EditorBridgeVertex
extends EditorScalable

enum Type { START, WAY, END }
const DEFAULT_TYPE = Type.WAY

var type = DEFAULT_TYPE


func _init(vertex: VertexData):
	super(vertex, EditorPhysicsLayer.BRIDGE_VERTEX)
	_collision_points = [Vector2.ZERO]


func _enter_tree():
	_source.bind(&"pos").to(self, &"position")


func _exit_tree():
	_source.unbind(&"pos").from(self, &"position")


func _scaled_draw(drawing_scale: float) -> void:
	var color: Color
	if selecting:
		match type:
			Type.START:
				color = setting.start_point_selecting_color
			Type.WAY:
				color = setting.selecting_color
			Type.END:
				color = setting.end_point_selecting_color
	elif selected:
		color = setting.selected_color
	else:
		return

	var radius = setting.selection_radius / drawing_scale
	draw_circle(Vector2.ZERO, radius, color)


func _on_selecting_changed():
	super()
	_update_process()


func _on_selected_changed():
	super()
	_update_process()


func _update_z_index():
	super()
	z_index += 10


func _update_process():
	set_process(selecting or selected)
