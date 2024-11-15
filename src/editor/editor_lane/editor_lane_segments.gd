class_name EditorLaneSegments
extends EditorSelectable

var lane: EditorLaneData:
	get:
		return _lane

var _editor_global = editor_global

var _lane: EditorLaneData

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


func _init(data: EditorLaneData):
	super(EditorPhysicsLayer.LANE_SEGMENTS)
	name = data.id

	_lane = data

	var source = _editor_global.source_db.get_or_add(data, &'notified')
	source.bind(&"vertex_ids").using(_get_vertices).to(self, &"_vertices")


func _draw():
	var points = _vertices.map(VertexData.pos_of)
	if len(points) < 2:
		return

	draw_polyline(points, setting.lane_color, setting.lane_width)

	var color: Color
	if selecting:
		color = setting.lane_selecting_color
	elif selected:
		color = setting.lane_selected_color
	else:
		return

	var width = setting.selection_radius / zoom_factor
	var radius = width / 2
	draw_circle(points[0], radius, color)
	draw_polyline(points, color, width)
	draw_circle(points[-1], radius, color)


func get_center() -> Vector2:
	return _center


func _get_vertices(vertex_ids: Array[StringName]) -> Array[VertexData]:
	var vertices = vertex_ids.map(_editor_global.lane_vertex_db.get_of)
	return Array(vertices, TYPE_OBJECT, &"RefCounted", VertexData)


func _add_segment_collision_shapes(vertices: Array[VertexData]):
	var sources = vertices.map(_editor_global.source_db.get_or_add)

	for index in range(len(sources) - 1):
		var source0 = sources[index]
		var source1 = sources[index + 1]

		var segment_shape = SegmentShape2D.new()
		source0.bind(&"pos").to(segment_shape, &"a")
		source1.bind(&"pos").to(segment_shape, &"b")

		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = segment_shape

		add_child(collision_shape)
		_collision_shape_dict[source0] = collision_shape

	for source in sources:
		source.add_callback(&"x", queue_redraw)
		source.add_callback(&"y", queue_redraw)


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
		source.remove_callback(&"x", queue_redraw)
		source.remove_callback(&"y", queue_redraw)


func _update_center():
	var curve = Curve2D.new()
	for vertex in _vertices:
		curve.add_point(vertex.pos)

	var length = curve.get_baked_length()
	_center = curve.sample_baked(length / 2)
