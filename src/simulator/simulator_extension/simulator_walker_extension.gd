class_name SimulatorWalkerExtension
extends SimulatorAgentExtension

var current_bridge_ext: SimulatorBridgeExtension
var forward: bool

var diameter: float
var distance_slope: float

var walker: WalkerData:
	get:
		return _data


func _init(data: WalkerData):
	super(data)

	diameter = data.radius * 2
	distance_slope = _data.public_distance - _data.personal_distance


func spawn_at(space_ext: SimulatorSpaceExtension, pos: float, step: int):
	super(space_ext, pos, step)

	var bridge_ext = space_ext as SimulatorBridgeExtension

	if pos < 0:
		bridge_ext.agent_exts.push_front(self)
		bridge_ext.backward_arrange_walker_exts_from_start()
	else:
		bridge_ext.agent_exts.push_back(self)
		bridge_ext.forward_arrange_walker_exts_from_end()


func move_to(bridge_ext: SimulatorBridgeExtension, step: int):
	if current_bridge_ext.start_vertex_id == bridge_ext.start_vertex_id:
		over_last_pos = bridge_ext.length + current_bridge_ext.length - over_last_pos
		_data.pos_history[-1] = bridge_ext.length + current_bridge_ext.length - _data.pos_history[-1]
		forward = true

	elif current_bridge_ext.start_vertex_id == bridge_ext.end_vertex_id:
		over_last_pos -= current_bridge_ext.length
		_data.pos_history[-1] -= current_bridge_ext.length
		forward = false

	elif current_bridge_ext.end_vertex_id == bridge_ext.start_vertex_id:
		over_last_pos += bridge_ext.length
		_data.pos_history[-1] += bridge_ext.length
		forward = true

	elif current_bridge_ext.end_vertex_id == bridge_ext.end_vertex_id:
		over_last_pos = -over_last_pos
		_data.pos_history[-1] = -_data.pos_history[-1]
		forward = false

	_enter([bridge_ext], step)

	if forward:
		bridge_ext.agent_exts.push_back(self)
		bridge_ext.forward_arrange_walker_exts_from_end()
	else:
		bridge_ext.agent_exts.push_front(self)
		bridge_ext.backward_arrange_walker_exts_from_start()


func _enter(space_exts: Array[SimulatorSpaceExtension], step: int):
	super(space_exts, step)
	current_bridge_ext = space_exts.back()


static func is_forward(walker_ext: SimulatorWalkerExtension):
	return walker_ext.forward


static func is_backward(walker_ext: SimulatorWalkerExtension):
	return not walker_ext.forward
