extends "res://src/editor/editor_tool/editor_tool_base_pointer.gd"

const TOOL_DISPLAY_NAME = "Add Lane tool"
const TOOL_STATUS_HINT = "Left click: add a point, Right click: commit the lane"

enum Phase { EMPTY, LACK, ENOUGH }

var _points: PackedVector2Array

var _prev_lanes: Array[LaneData]
var _next_lanes: Array[LaneData]

var _phase: Phase:
	get:
		match len(_points):
			0, 1:
				return Phase.EMPTY
			2:
				return Phase.LACK
			_:
				return Phase.ENOUGH

var _selecting_start_vertex_node: EditorLaneVertex:
	get:
		return _selecting_start_vertex_node
	set(next):
		var prev = _selecting_start_vertex_node

		if prev != null:
			prev.selecting = false
			prev.type = EditorLaneVertex.DEFAULT_TYPE

		if next != null:
			next.selecting = true
			next.type = EditorLaneVertex.Type.START

		_selecting_start_vertex_node = next

var _selecting_end_vertex_node: EditorLaneVertex:
	get:
		return _selecting_end_vertex_node
	set(next):
		var prev = _selecting_end_vertex_node

		if prev != null:
			prev.selecting = false
			prev.type = EditorLaneVertex.DEFAULT_TYPE

		if next != null:
			next.selecting = true
			next.type = EditorLaneVertex.Type.END

		_selecting_end_vertex_node = next

var _selecting_prev_segments_nodes: Array[EditorLaneSegments]:
	get:
		return _selecting_prev_segments_nodes
	set(next):
		var prev = _selecting_prev_segments_nodes

		for segments_node in prev:
			segments_node.selecting = false

		for segments_node in next:
			segments_node.selecting = true

		_selecting_prev_segments_nodes = next

var _selecting_next_segments_nodes: Array[EditorLaneSegments]:
	get:
		return _selecting_next_segments_nodes
	set(next):
		var prev = _selecting_next_segments_nodes

		for segments_node in prev:
			segments_node.selecting = false

		for segments_node in next:
			segments_node.selecting = true

		_selecting_next_segments_nodes = next

var _current_pos: Vector2:
	get:
		if _selecting_end_vertex_node == null:
			return get_local_mouse_position()
		else:
			return _selecting_end_vertex_node.data.pos

@onready var _lane_vertex_db = _editor_global.content_db.get_group(&"lane_vertices")
@onready var _lane_db = _editor_global.content_db.get_group(&"lanes")


func _draw():
	if len(_points) < 2:
		return

	var color = Color(setting.lane_color, 0.5)
	LaneHelper.draw_to(self, _points, color, setting.lane_width)


func _unhandled_input(event: InputEvent):
	super(event)

	if event is InputEventMouseMotion:
		_update_end_point()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if event.alt_pressed:
				_commit_lane()
			else:
				_add_new_point()

		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			_commit_lane()

	elif event.is_action_pressed(&"ui_cancel"):
		_cancel()


func get_display_name() -> String:
	return TOOL_DISPLAY_NAME


func get_status_hint() -> String:
	return TOOL_STATUS_HINT


func deactivate() -> void:
	super()

	_cancel()
	_unselect()


func _get_mask() -> int:
	return EditorPhysicsLayer.LANE_VERTEX


func _on_pointer_area_area_entered(area):
	super(area)
	_update_selecting_nodes()


func _on_pointer_area_area_exited(area):
	super(area)
	_update_selecting_nodes()


func _update_end_point():
	if _phase == Phase.EMPTY:
		return

	_points[-1] = _current_pos
	queue_redraw()


func _update_selecting_nodes():
	var phase = _phase

	if _hovered_items.is_empty():
		if phase == Phase.EMPTY:
			_prev_lanes = []
			_selecting_start_vertex_node = null
			_selecting_prev_segments_nodes = []
		else:
			_next_lanes = []
			_selecting_end_vertex_node = null
			_selecting_next_segments_nodes = []

		return

	var vertex_node = _hovered_items.back() as EditorLaneVertex
	var vertex_id = vertex_node.data.id
	var constraint = _editor_global.constraint_db.of(vertex_id) as EditorLaneVertexConstraint
	var related_lanes = constraint.lane_set.to_array()

	if _phase == Phase.EMPTY:
		var prev_segments_nodes: Array[EditorLaneSegments]

		for lane in related_lanes:
			if lane.vertex_ids.back() == vertex_id:
				var segments_node = _editor_global.content_node_of(lane.id)
				prev_segments_nodes.append(segments_node)

		if prev_segments_nodes.is_empty():
			_prev_lanes = []
			_selecting_start_vertex_node = null
			_selecting_prev_segments_nodes = []
		else:
			_prev_lanes.assign(prev_segments_nodes.map(EditorContent.data_of))
			_selecting_start_vertex_node = vertex_node
			_selecting_prev_segments_nodes = prev_segments_nodes

	else:
		var next_segments_nodes: Array[EditorLaneSegments]

		for lane in related_lanes:
			if lane.vertex_ids.front() == vertex_id:
				var segments_node = _editor_global.content_node_of(lane.id)
				next_segments_nodes.append(segments_node)

		if next_segments_nodes.is_empty():
			_next_lanes = []
			_selecting_end_vertex_node = null
			_selecting_next_segments_nodes = []
		else:
			_next_lanes.assign(next_segments_nodes.map(EditorContent.data_of))
			_selecting_end_vertex_node = vertex_node
			_selecting_next_segments_nodes = next_segments_nodes


func _add_new_point():
	var current_pos = _current_pos

	var empty = _phase == Phase.EMPTY
	if empty:
		if _selecting_start_vertex_node != null:
			current_pos = _selecting_start_vertex_node.data.pos

		_points.append(current_pos)

	_points.append(current_pos)

	if _selecting_end_vertex_node == null:
		return

	_commit_lane()


func _commit_lane():
	if _phase != Phase.ENOUGH:
		_cancel()
		return

	var point_count = len(_points) - 1
	_points.remove_at(point_count)

	var vertex_ids: Array[StringName]
	var new_vertices: Array[VertexData]

	for point in _points:
		var vertex = VertexData.from_dict({})
		vertex.pos = point
		vertex_ids.append(vertex.id)
		new_vertices.append(vertex)

	if _selecting_start_vertex_node != null:
		vertex_ids[0] = _selecting_start_vertex_node.data.id
		new_vertices.pop_front()

	if _selecting_end_vertex_node != null:
		vertex_ids[-1] = _selecting_end_vertex_node.data.id
		new_vertices.pop_back()

	var next_option_dict: Dictionary

	for lane in _next_lanes:
		var option = LaneData.OptionData.from_dict({})
		next_option_dict[lane.id] = option

	var new_lane = LaneData.from_dict({})
	new_lane.vertex_ids = vertex_ids
	new_lane.next_option_dict = next_option_dict

	if not setting.force_default_lane_traffic:
		new_lane.traffic = _calc_initial_traffic()

	if not setting.force_default_lane_speed_limit:
		new_lane.speed_limit = _calc_initial_speed_limit()

	_editor_global.undo_redo.create_action("Add lane")

	for vertex in new_vertices:
		_editor_global.undo_redo.add_do_method(_lane_vertex_db.add.bind(vertex))
		_editor_global.undo_redo.add_do_reference(vertex)
		_editor_global.undo_redo.add_undo_method(_lane_vertex_db.remove.bind(vertex))

	_editor_global.undo_redo.add_do_method(_lane_db.add.bind(new_lane))
	_editor_global.undo_redo.add_do_reference(new_lane)
	_editor_global.undo_redo.add_undo_method(_lane_db.remove.bind(new_lane))

	for lane in _prev_lanes:
		var option = LaneData.OptionData.from_dict({})

		var prev = lane.next_option_dict
		var next = prev.duplicate()
		next[new_lane.id] = option

		var source = _editor_global.source_db.get_or_add(lane)
		_editor_global.undo_redo.add_do_property(source, &"next_option_dict", next)
		_editor_global.undo_redo.add_undo_property(source, &"next_option_dict", prev)

	_editor_global.undo_redo.commit_action()

	_cancel()
	_unselect()


func _cancel():
	_points.clear()
	queue_redraw()

	_unselect()


func _unselect():
	_prev_lanes.clear()
	_next_lanes.clear()
	_selecting_prev_segments_nodes = []
	_selecting_next_segments_nodes = []
	_selecting_start_vertex_node = null
	_selecting_end_vertex_node = null


func _calc_initial_traffic() -> float:
	if _prev_lanes.is_empty():
		return setting.default_lane_traffic

	var initial_traffic = 0.0

	for lane in _prev_lanes:
		if lane.traffic == 0.0:
			continue

		var options = lane.next_option_dict.values()
		var weights = options.map(func(option): return option.weight)
		var sum_weight = weights.reduce(func(accum, weight): return accum + weight, 1.0)

		initial_traffic += lane.traffic / sum_weight

	return initial_traffic


func _calc_initial_speed_limit() -> int:
	var sum_speed_limit = 0.0

	for lane in _prev_lanes:
		sum_speed_limit += lane.speed_limit

	for lane in _next_lanes:
		sum_speed_limit += lane.speed_limit

	var lane_count = len(_prev_lanes) + len(_next_lanes)
	var average_speed_limit = sum_speed_limit / lane_count

	var initial_speed_limit = roundi(average_speed_limit / 10) * 10
	if initial_speed_limit == 0:
		initial_speed_limit = setting.default_lane_speed_limit

	return initial_speed_limit


static func _get_lanes(segments_nodes: Array[EditorLaneSegments]) -> Array[LaneData]:
	var lanes = segments_nodes.map(EditorContent.data_of)
	return Array(lanes, TYPE_OBJECT, &"RefCounted", LaneData)
