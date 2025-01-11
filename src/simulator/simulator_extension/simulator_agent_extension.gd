class_name SimulatorAgentExtension

var over_last_pos: float

var agent: AgentData:
	get:
		return _data

var _data: AgentData


func _init(data: AgentData):
	_data = data


func spawn_at(space_ext: SimulatorSpaceExtension, pos: float, step: int):
	over_last_pos = pos
	_data.spawn_step = step
	_data.die_step = -1
	_data.pos_history.append(pos)
	_enter(space_ext, step - 1)


func die(step: int):
	assert(len(_data.pos_history) == step - _data.spawn_step + 2)
	_data.die_step = step + 1


func _enter(space_ext: SimulatorSpaceExtension, step: int):
	var moved_index = step - _data.spawn_step + 1
	assert(len(_data.pos_history) == moved_index + 1)
	_data.space_history[moved_index] = space_ext.id
