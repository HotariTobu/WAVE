class_name EditorLane
extends EditorSelectable

var _editor_global = editor_global

var _vertices: Array[VertexData]:
	get:
		return _vertices
	set(next):
		var prev = _vertices
		_vertices = next
		_remove_segment_collision_shapes(prev)
		_add_segment_collision_shapes(next)
		queue_redraw()

var _collision_shape_dict = {}


func _init(data: LaneData):
	var source = _editor_global.source_db.get_or_add(data)
	source.bind("vertex_ids").using(_get_vertices).to(self, "_vertices")


func _draw():
	var color: Color
	if selecting:
		color = setting.lane_selecting_color
	elif selected:
		color = setting.lane_selected_color
	else:
		return

	var points = _vertices.map(VertexData.to_vector)
	if len(points) < 2:
		return

	var width = setting.selection_radius / zoom_factor
	var radius = width / 2
	draw_circle(points[0], radius, color)
	draw_polyline(points, color, width)
	draw_circle(points[-1], radius, color)


func _get_vertices(vertex_ids: Array[StringName]) -> Array[VertexData]:
	return vertex_ids.map(_editor_global.vertex_dict.get)


func _add_segment_collision_shapes(vertices: Array[VertexData]):
	var sources = vertices.map(_editor_global.source_db.get_or_add)

	for index in range(len(sources) - 1):
		var source0 = sources[index]
		var source1 = sources[index + 1]

		var segment_shape = SegmentShape2D.new()
		source0.bind("pos").to(segment_shape, "a")
		source1.bind("pos").to(segment_shape, "b")

		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = segment_shape

		add_child(collision_shape)
		_collision_shape_dict[source0] = collision_shape

	for source in sources:
		source.add_callback("x", queue_redraw)
		source.add_callback("y", queue_redraw)


func _remove_segment_collision_shapes(vertices: Array[VertexData]):
	var sources = vertices.map(_editor_global.source_db.get_or_add)

	for index in range(len(sources) - 1):
		var source0 = sources[index]
		var source1 = sources[index + 1]

		var collision_shape = _collision_shape_dict[source0]
		var segment_shape = collision_shape.shape

		source0.unbind("pos").from(segment_shape, "a")
		source1.unbind("pos").from(segment_shape, "b")

		remove_child(collision_shape)
		_collision_shape_dict.erase(source0)

	for source in sources:
		source.remove_callback("x", queue_redraw)
		source.remove_callback("y", queue_redraw)
