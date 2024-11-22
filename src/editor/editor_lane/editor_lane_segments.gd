class_name EditorLaneSegments
extends EditorBlockTargetable

var _collision_shape_dict: Dictionary

var _center: Vector2

var _vertices: Array[VertexData]:
	get:
		return _vertices
	set(next):
		var prev = _vertices
		_vertices = next
		_remove_segment_collision_shapes(prev)
		_add_segment_collision_shapes(next)
		queue_redraw()
		_update_center()

var _lane_vertex_db = _editor_global.content_db.get_group(&"lane_vertices")


func _init(lane: LaneData):
	super(lane, EditorPhysicsLayer.LANE_SEGMENTS)


func _enter_tree():
	_source.bind(&"vertex_ids").using(_get_vertices_of).to(self, &"_vertices")


func _exit_tree():
	_source.unbind(&"vertex_ids").from(self, &"_vertices")


func _draw():
	var points = _vertices.map(VertexData.pos_of)
	if len(points) < 2:
		return

	Lane.draw_to(self, points, setting.lane_color, setting.lane_width)

	var color: Color
	if block_targeting:
		color = setting.lane_block_targeting_color
	elif selecting:
		color = setting.selecting_color
	elif block_targeted:
		color = setting.lane_block_targeted_color
	elif selected:
		color = setting.selected_color
	else:
		return

	var width = setting.selection_radius / zoom_factor
	var radius = width / 2
	draw_circle(points[0], radius, color)
	draw_polyline(points, color, width)
	draw_circle(points[-1], radius, color)


func get_local_center() -> Vector2:
	return _center


func get_movable_nodes():
	return _data.vertex_ids.map(_editor_global.get_content_node)


func _get_vertices_of(vertex_ids: Array[StringName]) -> Array[VertexData]:
	var vertices = vertex_ids.map(_lane_vertex_db.data_of)
	return Array(vertices, TYPE_OBJECT, &"RefCounted", VertexData)


func _add_segment_collision_shapes(vertices: Array[VertexData]):
	var sources = vertices.map(_editor_global.source_db.get_or_add)

	for index in range(len(sources) - 1):
		var source0 = sources[index]
		var source1 = sources[index + 1]

		var collision_shape = create_segment()
		var segment_shape = collision_shape.shape

		source0.bind(&"pos").to(segment_shape, &"a")
		source1.bind(&"pos").to(segment_shape, &"b")

		add_child(collision_shape)
		_collision_shape_dict[source0] = collision_shape

	for source in sources:
		source.add_callback(&"pos", queue_redraw)


func _remove_segment_collision_shapes(vertices: Array[VertexData]):
	var sources = vertices.map(_editor_global.source_db.get_or_add)

	for index in range(len(sources) - 1):
		var source0 = sources[index]
		var source1 = sources[index + 1]

		var collision_shape = _collision_shape_dict[source0]
		var segment_shape = collision_shape.shape

		source0.unbind(&"pos").from(segment_shape, &"a")
		source1.unbind(&"pos").from(segment_shape, &"b")

		remove_child(collision_shape)
		_collision_shape_dict.erase(source0)

	for source in sources:
		source.remove_callback(&"pos", queue_redraw)


func _update_center():
	var points = _vertices.map(VertexData.pos_of)
	if len(points) < 2:
		return

	var curve = Curve2D.new()
	for point in points:
		curve.add_point(point)

	var length = curve.get_baked_length()
	_center = curve.sample_baked(length / 2)
