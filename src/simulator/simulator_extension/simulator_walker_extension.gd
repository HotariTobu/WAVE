class_name SimulatorWalkerExtension
extends SimulatorAgentExtension

var current_bridge_ext: SimulatorBridgeExtension
var forward: bool

var diameter: float

var walker: WalkerData:
	get:
		return _data


func _init(data: WalkerData):
	super(data)

	diameter = data.radius * 2


func move_to(bridge_ext: SimulatorBridgeExtension, step: int):
	if current_bridge_ext.start_vertex_id == bridge_ext.start_vertex_id:
		over_last_pos = -over_last_pos
		_data.pos_history[-1] = -_data.pos_history[-1]
		forward = false

	elif current_bridge_ext.start_vertex_id == bridge_ext.end_vertex_id:
		over_last_pos += bridge_ext.length
		_data.pos_history[-1] += bridge_ext.length
		forward = true

	elif current_bridge_ext.end_vertex_id == bridge_ext.start_vertex_id:
		over_last_pos -= current_bridge_ext.length
		_data.pos_history[-1] -= current_bridge_ext.length
		forward = false

	elif current_bridge_ext.end_vertex_id == bridge_ext.end_vertex_id:
		over_last_pos = bridge_ext.length + current_bridge_ext.length - over_last_pos
		_data.pos_history[-1] = bridge_ext.length + current_bridge_ext.length - _data.pos_history[-1]
		forward = true

	_enter(bridge_ext, step)


func _enter(space_ext: SimulatorSpaceExtension, step: int):
	super(space_ext, step)
	current_bridge_ext = space_ext
