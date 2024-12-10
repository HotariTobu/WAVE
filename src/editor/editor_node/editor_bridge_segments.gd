class_name EditorBridgeSegments
extends EditorBlockTargetable

var _vertices: Array[VertexData]:
	get:
		return _vertices
	set(next):
		var prev = _vertices

		for vertex in prev:
			var source = _editor_global.source_db.get_or_add(vertex)
			source.remove_callback(&"pos", queue_redraw)

		for vertex in next:
			var source = _editor_global.source_db.get_or_add(vertex)
			source.add_callback(&"pos", queue_redraw)

		_vertices = next
		queue_redraw()

var _bridge_vertex_db = _editor_global.content_db.get_group(&"bridge_vertices")


func _init(bridge: BridgeData):
	super(bridge, EditorPhysicsLayer.BRIDGE_SEGMENTS)


func _enter_tree():
	_source.bind(&"vertex_ids").using(_get_vertices_of).to(self, &"_vertices")
	_source.add_callback(&"width_limit", queue_redraw)


func _exit_tree():
	_source.unbind(&"vertex_ids").from(self, &"_vertices")
	_source.remove_callback(&"width_limit", queue_redraw)


func _draw():
	_collision_points = _vertices.map(VertexData.pos_of)
	if len(_collision_points) < 2:
		return

	var color: Color
	if block_targeting:
		color = setting.block_targeting_color
	elif selecting:
		color = setting.selecting_color
	elif block_targeted:
		color = setting.block_targeted_color
	elif selected:
		color = setting.selected_color
	else:
		color = setting.bridge_color

	var width = setting.bridge_width * _data.width_limit
	draw_polyline(_collision_points, color, width)


func _get_vertices_of(vertex_ids: Array[StringName]) -> Array[VertexData]:
	var vertices = vertex_ids.map(_bridge_vertex_db.data_of)
	return Array(vertices, TYPE_OBJECT, &"RefCounted", VertexData)
