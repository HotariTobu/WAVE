class_name SimulatorAgentExtension

var agent: AgentData:
	get:
		return _data

var _data: AgentData


func _init(data: AgentData):
	_data = data


func spawn_at(space_ext: SimulatorSpaceExtension, pos: float, step: int):
	_data.spawn_step = step
	_data.die_step = -1
	_data.pos_history.append(pos)
	_enter(space_ext, step - 1)


func move_to(space_ext: SimulatorSpaceExtension, step: int):
	_data.pos_history[-1] += space_ext.length
	_enter(space_ext, step)


func die(step: int):
	_data.die_step = step + 1


func _enter(space_ext: SimulatorSpaceExtension, step: int):
	var moved_index = step - _data.spawn_step + 1
	assert(len(_data.pos_history) - 1 == moved_index)
	_data.space_history[moved_index] = space_ext.id
	space_ext.agent_exts.append(self)
