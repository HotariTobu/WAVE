extends EditorTool

const TOOL_DISPLAY_NAME = "Add Lane tool"
const TOOL_STATUS_HINT = "Left click: add a point, Right click: commit the lane"

enum Phase { EMPTY, LACK, ENOUGH }

var _editor_global = editor_global

var _vertices: Array[VertexData]

var _hovered_lane_vertex_nodes: Array[EditorLaneVertex]
var _hovered_lane_segments_nodes: Array[EditorLaneSegments]

var _prev_lanes: Array[LaneData]
var _next_lanes: Array[LaneData]

var _phase: Phase:
	get:
		var vertex_count = len(_vertices)
		if vertex_count < 2:
			return Phase.EMPTY
		elif vertex_count < 3:
			return Phase.LACK
		else:
			return Phase.ENOUGH

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

var _selecting_vertex_node: EditorLaneVertex:
	get:
		return _selecting_vertex_node
	set(next):
		var prev = _selecting_vertex_node

		if prev != null:
			prev.selecting = false
			prev.type = EditorLaneVertex.DEFAULT_TYPE

		if next != null:
			next.selecting = true

		_selecting_vertex_node = next

var _current_vertex: VertexData:
	get:
		if _selecting_vertex_node == null:
			var vertex = VertexData.new()
			vertex.pos = get_local_mouse_position()
			return vertex
		else:
			return _selecting_vertex_node.data

@onready var _lane_vertex_db = _editor_global.content_db.get_group(&"lane_vertices")
@onready var _lane_db = _editor_global.content_db.get_group(&"lanes")


func _ready():
	set_process_unhandled_input(false)


func _draw():
	if len(_vertices) < 2:
		return

	var points = _vertices.map(VertexData.pos_of)
	draw_polyline(points, setting.preview_lane_color)


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		_pointer_area.position = get_local_mouse_position()
		_update_end_point()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_add_new_point()

		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			_commit_lane()

	elif event.is_action_pressed(&"ui_cancel"):
		_cancel()


func get_display_name() -> String:
	return TOOL_DISPLAY_NAME


func get_status_hint() -> String:
	return TOOL_STATUS_HINT


func activate() -> void:
	set_process_unhandled_input(true)

	_pointer_area.collision_mask = EditorPhysicsLayer.LANE

	_pointer_area.area_entered.connect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.connect(_on_pointer_area_area_exited)


func deactivate() -> void:
	set_process_unhandled_input(false)

	_pointer_area.collision_mask = 0

	_pointer_area.area_entered.disconnect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.disconnect(_on_pointer_area_area_exited)

	_cancel()
	_hovered_lane_vertex_nodes.clear()
	_hovered_lane_segments_nodes.clear()
	_unselect()


func _on_pointer_area_area_entered(area):
	if area is EditorLaneVertex:
		_hovered_lane_vertex_nodes.append(area)
	elif area is EditorLaneSegments:
		_hovered_lane_segments_nodes.append(area)
	else:
		return

	_update_selecting_nodes()


func _on_pointer_area_area_exited(area):
	if area is EditorLaneVertex:
		_hovered_lane_vertex_nodes.erase(area)
	elif area is EditorLaneSegments:
		_hovered_lane_segments_nodes.erase(area)
	else:
		return

	_update_selecting_nodes()


func _update_end_point():
	if _phase == Phase.EMPTY:
		return

	_vertices[-1] = _current_vertex
	queue_redraw()


func _add_new_point():
	var empty = _phase == Phase.EMPTY
	if empty:
		_vertices.append(_current_vertex)

	_vertices.append(_current_vertex)

	if _selecting_vertex_node == null:
		return

	if empty:
		_prev_lanes = _get_lanes(_selecting_prev_segments_nodes)
		_unselect()
	else:
		_next_lanes = _get_lanes(_selecting_next_segments_nodes)
		_commit_lane()


func _commit_lane():
	if _phase != Phase.ENOUGH:
		_cancel()
		return

	_vertices.pop_back()

	var vertex_ids: Array[StringName]
	var new_vertices: Array[VertexData]

	for vertex in _vertices:
		var vertex_id = vertex.id
		vertex_ids.append(vertex_id)

		if _lane_vertex_db.has_of(vertex_id):
			continue

		new_vertices.append(vertex)

	var next_option_dict: Dictionary

	for lane in _next_lanes:
		var option = LaneData.OptionData.new()
		option.weight = setting.default_option_weight
		next_option_dict[lane.id] = option

	var new_lane = LaneData.new()
	new_lane.vertex_ids = vertex_ids
	new_lane.traffic = _calc_initial_traffic()
	new_lane.speed_limit = _calc_initial_speed_limit()
	new_lane.next_option_dict = next_option_dict

	_editor_global.undo_redo.create_action("Add lane")

	for vertex in new_vertices:
		_editor_global.undo_redo.add_do_method(_lane_vertex_db.add.bind(vertex))
		_editor_global.undo_redo.add_do_reference(vertex)
		_editor_global.undo_redo.add_undo_method(_lane_vertex_db.remove.bind(vertex))

	_editor_global.undo_redo.add_do_method(_lane_db.add.bind(new_lane))
	_editor_global.undo_redo.add_do_reference(new_lane)
	_editor_global.undo_redo.add_undo_method(_lane_db.remove.bind(new_lane))

	for lane in _prev_lanes:
		var option = LaneData.OptionData.new()
		option.weight = setting.default_option_weight

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
	_vertices.clear()
	queue_redraw()

	_prev_lanes.clear()
	_next_lanes.clear()

	if _selecting_vertex_node == null:
		return

	if _selecting_vertex_node.type == EditorLaneVertex.Type.END:
		return

	_unselect()


func _update_selecting_nodes():
	var vertex_id_vertex_node_dict: Dictionary
	for lane_vertex_node in _hovered_lane_vertex_nodes:
		var vertex_id = lane_vertex_node.data.id
		vertex_id_vertex_node_dict[vertex_id] = lane_vertex_node

	var vertex_ids_segments_node_dict: Dictionary
	for lane_segments_node in _hovered_lane_segments_nodes:
		var vertex_ids = lane_segments_node.data.vertex_ids
		vertex_ids_segments_node_dict[vertex_ids] = lane_segments_node

	if _phase == Phase.EMPTY:
		for vertex_id in vertex_id_vertex_node_dict:
			var prev_segments_nodes: Array[EditorLaneSegments]

			for vertex_ids in vertex_ids_segments_node_dict:
				if vertex_id == vertex_ids.back():
					var segments_node = vertex_ids_segments_node_dict[vertex_ids]
					prev_segments_nodes.append(segments_node)

			if prev_segments_nodes.is_empty():
				continue

			_selecting_prev_segments_nodes = prev_segments_nodes
			_selecting_next_segments_nodes = []

			var vertex_node = vertex_id_vertex_node_dict[vertex_id]
			vertex_node.type = EditorLaneVertex.Type.START
			_selecting_vertex_node = vertex_node

			return

	else:
		for vertex_id in vertex_id_vertex_node_dict:
			var next_segments_nodes: Array[EditorLaneSegments]

			for vertex_ids in vertex_ids_segments_node_dict:
				if vertex_id == vertex_ids.front():
					var segments_node = vertex_ids_segments_node_dict[vertex_ids]
					next_segments_nodes.append(segments_node)

			if next_segments_nodes.is_empty():
				continue

			_selecting_prev_segments_nodes = []
			_selecting_next_segments_nodes = next_segments_nodes

			var vertex_node = vertex_id_vertex_node_dict[vertex_id]
			vertex_node.type = EditorLaneVertex.Type.END
			_selecting_vertex_node = vertex_node

			return

	_unselect()


func _unselect():
	_selecting_prev_segments_nodes = []
	_selecting_next_segments_nodes = []
	_selecting_vertex_node = null


func _calc_initial_traffic() -> float:
	if setting.force_default_lane_traffic:
		return setting.default_lane_traffic
		
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
	if setting.force_default_lane_speed_limit:
		return setting.default_lane_speed_limit
		
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
