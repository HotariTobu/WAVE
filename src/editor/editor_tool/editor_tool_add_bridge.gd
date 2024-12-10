extends "res://src/editor/editor_tool/editor_tool_base_pointer.gd"

const TOOL_DISPLAY_NAME = "Add Bridge tool"
const TOOL_STATUS_HINT = "Left click: add a point, Right click: commit the bridge"

enum Phase { EMPTY, LACK, ENOUGH }

var _editor_global = editor_global

var _points: PackedVector2Array

var _prev_bridges: Array[BridgeData]
var _next_bridges: Array[BridgeData]

var _phase: Phase:
	get:
		match len(_points):
			0, 1:
				return Phase.EMPTY
			2:
				return Phase.LACK
			_:
				return Phase.ENOUGH

var _selecting_start_vertex_node: EditorBridgeVertex:
	get:
		return _selecting_start_vertex_node
	set(next):
		var prev = _selecting_start_vertex_node

		if prev != null:
			prev.selecting = false
			prev.type = EditorBridgeVertex.DEFAULT_TYPE

		if next != null:
			next.selecting = true
			next.type = EditorBridgeVertex.Type.START

		_selecting_start_vertex_node = next

var _selecting_end_vertex_node: EditorBridgeVertex:
	get:
		return _selecting_end_vertex_node
	set(next):
		var prev = _selecting_end_vertex_node

		if prev != null:
			prev.selecting = false
			prev.type = EditorBridgeVertex.DEFAULT_TYPE

		if next != null:
			next.selecting = true
			next.type = EditorBridgeVertex.Type.END

		_selecting_end_vertex_node = next

var _selecting_prev_segments_nodes: Array[EditorBridgeSegments]:
	get:
		return _selecting_prev_segments_nodes
	set(next):
		var prev = _selecting_prev_segments_nodes

		for segments_node in prev:
			segments_node.selecting = false

		for segments_node in next:
			segments_node.selecting = true

		_selecting_prev_segments_nodes = next

var _selecting_next_segments_nodes: Array[EditorBridgeSegments]:
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

@onready var _bridge_vertex_db = _editor_global.content_db.get_group(&"bridge_vertices")
@onready var _bridge_db = _editor_global.content_db.get_group(&"bridges")


func _draw():
	if len(_points) < 2:
		return

	var color = Color(setting.bridge_color, 0.5)
	var width = setting.bridge_width * setting.default_bridge_width_limit
	draw_polyline(_points, color, width)


func _unhandled_input(event: InputEvent):
	super(event)

	if event is InputEventMouseMotion:
		_update_end_point()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if event.alt_pressed:
				_commit()
			else:
				_add_new_point()

		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			_commit()

	elif event.is_action_pressed(&"ui_cancel"):
		_cancel()


func get_display_name() -> String:
	return TOOL_DISPLAY_NAME


func get_status_hint() -> String:
	return TOOL_STATUS_HINT


func deactivate() -> void:
	super()

	_cancel()


func _get_mask() -> int:
	return EditorPhysicsLayer.BRIDGE_VERTEX


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
			_prev_bridges = []
			_selecting_start_vertex_node = null
			_selecting_prev_segments_nodes = []
		else:
			_next_bridges = []
			_selecting_end_vertex_node = null
			_selecting_next_segments_nodes = []

		return

	var vertex_node = _hovered_items.back() as EditorBridgeVertex
	var vertex_id = vertex_node.data.id
	var constraint = _editor_global.constraint_db.of(vertex_id) as EditorBridgeVertexConstraint
	var related_bridges = constraint.bridge_set.to_array()

	var segments_nodes: Array[EditorBridgeSegments]

	for bridge in related_bridges:
		if bridge.vertex_ids.front() == vertex_id or bridge.vertex_ids.back() == vertex_id:
			var segments_node = _editor_global.content_node_of(bridge.id)
			segments_nodes.append(segments_node)

	if _phase == Phase.EMPTY:
		if segments_nodes.is_empty():
			_prev_bridges = []
			_selecting_start_vertex_node = null
			_selecting_prev_segments_nodes = []
		else:
			_prev_bridges.assign(segments_nodes.map(EditorSelectable.data_of))
			_selecting_start_vertex_node = vertex_node
			_selecting_prev_segments_nodes = segments_nodes

	else:
		if segments_nodes.is_empty():
			_next_bridges = []
			_selecting_end_vertex_node = null
			_selecting_next_segments_nodes = []
		else:
			_next_bridges.assign(segments_nodes.map(EditorSelectable.data_of))
			_selecting_end_vertex_node = vertex_node
			_selecting_next_segments_nodes = segments_nodes


func _add_new_point():
	var current_pos = _current_pos

	if _phase == Phase.EMPTY:
		if _selecting_start_vertex_node != null:
			current_pos = _selecting_start_vertex_node.data.pos

		_points.append(current_pos)

	_points.append(current_pos)

	if _selecting_end_vertex_node == null:
		return

	_commit()


func _commit():
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

	var prev_option_dict: Dictionary
	var next_option_dict: Dictionary

	for bridge in _prev_bridges:
		var option = BridgeData.OptionData.from_dict({})
		prev_option_dict[bridge.id] = option

	for bridge in _next_bridges:
		var option = BridgeData.OptionData.from_dict({})
		next_option_dict[bridge.id] = option

	var new_bridge = BridgeData.from_dict({})
	new_bridge.vertex_ids = vertex_ids
	new_bridge.prev_option_dict = prev_option_dict
	new_bridge.next_option_dict = next_option_dict

	if not setting.force_default_bridge_traffic:
		new_bridge.traffic = _calc_initial_traffic()

	if not setting.force_default_bridge_forward:
		new_bridge.forward = _calc_initial_forward()

	if not setting.force_default_bridge_width_limit:
		new_bridge.width_limit = _calc_initial_width_limit()

	_editor_global.undo_redo.create_action("Add bridge")

	for vertex in new_vertices:
		_editor_global.undo_redo.add_do_method(_bridge_vertex_db.add.bind(vertex))
		_editor_global.undo_redo.add_do_reference(vertex)
		_editor_global.undo_redo.add_undo_method(_bridge_vertex_db.remove.bind(vertex))

	_editor_global.undo_redo.add_do_method(_bridge_db.add.bind(new_bridge))
	_editor_global.undo_redo.add_do_reference(new_bridge)
	_editor_global.undo_redo.add_undo_method(_bridge_db.remove.bind(new_bridge))

	for bridge in _prev_bridges:
		var option = BridgeData.OptionData.from_dict({})

		var prev = bridge.next_option_dict
		var next = prev.duplicate()
		next[new_bridge.id] = option

		var source = _editor_global.source_db.get_or_add(bridge)
		_editor_global.undo_redo.add_do_property(source, &"next_option_dict", next)
		_editor_global.undo_redo.add_undo_property(source, &"next_option_dict", prev)

	for bridge in _next_bridges:
		var option = BridgeData.OptionData.from_dict({})

		var prev = bridge.prev_option_dict
		var next = prev.duplicate()
		next[new_bridge.id] = option

		var source = _editor_global.source_db.get_or_add(bridge)
		_editor_global.undo_redo.add_do_property(source, &"prev_option_dict", next)
		_editor_global.undo_redo.add_undo_property(source, &"prev_option_dict", prev)

	_editor_global.undo_redo.commit_action()

	_cancel()


func _cancel():
	_points.clear()
	queue_redraw()

	_unselect()


func _unselect():
	_prev_bridges.clear()
	_next_bridges.clear()
	_selecting_prev_segments_nodes = []
	_selecting_next_segments_nodes = []
	_selecting_start_vertex_node = null
	_selecting_end_vertex_node = null


func _calc_initial_traffic() -> float:
	if _prev_bridges.is_empty():
		return setting.default_lane_traffic

	var initial_traffic = 0.0

	for bridge in _prev_bridges:
		if bridge.traffic == 0.0:
			continue

		var options = bridge.next_option_dict.values()
		var weights = options.map(func(option): return option.weight)
		var sum_weight = weights.reduce(func(accum, weight): return accum + weight, 1.0)

		initial_traffic += bridge.traffic / sum_weight

	return initial_traffic


func _calc_initial_forward() -> int:
	var sum_forward = 0.0

	for bridge in _prev_bridges:
		sum_forward += bridge.forward

	for bridge in _next_bridges:
		sum_forward += bridge.forward

	var lane_count = len(_prev_bridges) + len(_next_bridges)
	var average_forward = sum_forward / lane_count

	return average_forward


func _calc_initial_width_limit() -> int:
	var sum_width_limit = 0.0

	for bridge in _prev_bridges:
		sum_width_limit += bridge.width_limit

	for bridge in _next_bridges:
		sum_width_limit += bridge.width_limit

	var lane_count = len(_prev_bridges) + len(_next_bridges)
	var average_width_limit = sum_width_limit / lane_count

	var initial_width_limit = ceili(average_width_limit)
	return initial_width_limit


static func _get_lanes(segments_nodes: Array[EditorBridgeSegments]) -> Array[BridgeData]:
	var lanes = segments_nodes.map(EditorSelectable.data_of)
	return Array(lanes, TYPE_OBJECT, &"RefCounted", BridgeData)
