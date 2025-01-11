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
	if pos < 0:
		space_ext.agent_exts.push_front(self)
	else:
		space_ext.agent_exts.push_back(self)


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

	_enter(bridge_ext, step)

	if forward:
		var index = len(bridge_ext.agent_exts)
		bridge_ext.agent_exts.push_back(self)
		bridge_ext.forward_arrange_walker_exts_from(index)
	else:
		bridge_ext.agent_exts.push_front(self)
		bridge_ext.backward_arrange_walker_exts_from(0)


func _enter(space_ext: SimulatorSpaceExtension, step: int):
	super(space_ext, step)
	current_bridge_ext = space_ext
