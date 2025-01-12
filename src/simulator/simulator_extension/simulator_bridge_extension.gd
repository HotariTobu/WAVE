class_name SimulatorBridgeExtension
extends SimulatorSpaceExtension

const TRAFFIC_FACTOR = 1.0 / 100.0

var traffic: float
var width_limit: int

var prev_option_dict: Dictionary
var next_option_dict: Dictionary

var start_vertex_id: StringName
var end_vertex_id: StringName

var next_bridge_exts: Array[SimulatorBridgeExtension]
var prev_bridge_exts: Array[SimulatorBridgeExtension]

var choose_prev_bridge_ext = null
var choose_next_bridge_ext = null
var loop_prev_bridge_ext_set = Set.new()
var loop_next_bridge_ext_set = Set.new()

var forward_is_closed: bool
var backward_is_closed: bool
var tails_array: Array[PackedFloat32Array]

# var tails_array: Array[PackedFloat32Array]:
# 	get:
# 		var agent_count = len(agent_exts)
# 		if agent_count == 0:
# 			return []

# 		var result: Array[PackedFloat32Array]
# 		result.resize(agent_count)

# 		var first_walker_ext = agent_exts[0] as SimulatorWalkerExtension
# 		var first_pos = first_walker_ext.walker.pos_history[-1]
# 		var first_tail = first_pos + first_walker_ext.diameter
# 		result[0].append(first_tail)

# 		for index in range(1, agent_count):
# 			var walker_ext = agent_exts[index] as SimulatorWalkerExtension
# 			var pos = walker_ext.walker.pos_history[-1]
# 			var tail = pos + walker_ext.diameter
# 			result[index].append(tail)

# 			var forward_tails = result[index - 1].duplicate()
# 			for offset in range(-1, -len(forward_tails) - 1, -1):
# 				var forward_tail = forward_tails[offset]
# 				if forward_tail < pos:
# 					break

# 				var tails = result[index + offset]
# 				tails.insert(tails.bsearch(tail), tail)
# 				result[index].append(forward_tail)

# 			result[index].reverse()

# 		return result

var bridge: BridgeData:
	get:
		return _data


func _init(data: BridgeData):
	super(data)


func extend(ext_of: Callable) -> void:
	super(ext_of)

	traffic = _data.traffic * TRAFFIC_FACTOR
	width_limit = _data.width_limit

	_assign_ext_dict(&"prev_option_dict", &"prev_option_dict", ext_of)
	_assign_ext_dict(&"next_option_dict", &"next_option_dict", ext_of)

	start_vertex_id = _data.vertex_ids[0]
	end_vertex_id = _data.vertex_ids[-1]

	prev_bridge_exts.assign(prev_option_dict.keys())
	next_bridge_exts.assign(next_option_dict.keys())
	prev_bridge_exts.make_read_only()
	next_bridge_exts.make_read_only()


func update_is_blocking(_time: float):
	is_blocking = not agent_exts.is_empty()


func update_tails_array():
	var walker_count = len(agent_exts)
	tails_array.resize(walker_count)

	if walker_count == 0:
		return

	_update_tails_array(0, walker_count)


func forward_arrange_walker_exts_from(index: int):
	var walker_ext = agent_exts[index] as SimulatorWalkerExtension
	var pos = walker_ext.walker.pos_history[-1]

	var forward_index = index - 1
	while forward_index >= 0:
		var forward_walker_ext = agent_exts[forward_index] as SimulatorWalkerExtension
		var forward_pos = forward_walker_ext.walker.pos_history[-1]
		if forward_pos < pos:
			break

		agent_exts[forward_index + 1] = forward_walker_ext
		agent_exts[forward_index] = walker_ext

		forward_index -= 1

	var tails_margin = len(tails_array[index])
	_update_tails_array(forward_index - tails_margin + 2, index + tails_margin - 1)


func forward_arrange_walker_exts_from_end():
	var walker_count = len(agent_exts)
	tails_array.resize(walker_count)
	forward_arrange_walker_exts_from(walker_count - 1)


func backward_arrange_walker_exts_from(index: int):
	var walker_ext = agent_exts[index] as SimulatorWalkerExtension
	var pos = walker_ext.walker.pos_history[-1]

	var backward_index = index + 1
	var walker_count = len(agent_exts)
	while backward_index < walker_count:
		var backward_walker_ext = agent_exts[backward_index] as SimulatorWalkerExtension
		var backward_pos = backward_walker_ext.walker.pos_history[-1]
		if pos < backward_pos:
			break

		agent_exts[backward_index - 1] = backward_walker_ext
		agent_exts[backward_index] = walker_ext

		backward_index += 1

	var tails_margin = len(tails_array[index])
	_update_tails_array(index - tails_margin + 1, backward_index + tails_margin - 2)


func backward_arrange_walker_exts_from_start():
	for _i in range(len(agent_exts) - len(tails_array)):
		tails_array.push_front(PackedFloat32Array())
	backward_arrange_walker_exts_from(0)


func _update_tails_array(start_index: int, end_index: int):
	var start = start_index
	if start_index < 1:
		start = 1

		var walker_ext = agent_exts[0] as SimulatorWalkerExtension
		var pos = walker_ext.walker.pos_history[-1]
		var tail = pos + walker_ext.diameter
		tails_array[0].clear()
		tails_array[0].append(tail)

	var end = mini(len(agent_exts), end_index + 1)

	for index in range(start, end):
		var walker_ext = agent_exts[index] as SimulatorWalkerExtension
		var pos = walker_ext.walker.pos_history[-1]
		var tail = pos + walker_ext.diameter
		tails_array[index].clear()
		tails_array[index].append(tail)

		var forward_tails = tails_array[index - 1].duplicate()
		for offset in range(-1, -len(forward_tails) - 1, -1):
			var forward_tail = forward_tails[offset]
			if forward_tail < pos:
				break

			var tails = tails_array[index + offset]
			tails.insert(tails.bsearch(tail), tail)
			tails_array[index].append(forward_tail)

		tails_array[index].reverse()

	assert(tails_array.all(func(tails): return len(tails) <= len(agent_exts)))


func validate_walker_order() -> bool:
	var last_pos = -INF

	for walker_ext in agent_exts:
		var walker = walker_ext.walker
		var pos = walker.pos_history[-1]
		if last_pos > pos:
			return false

		last_pos = pos

	return true
