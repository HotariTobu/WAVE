class_name SimulatorAgentExtension

var agent: AgentData:
	get:
		return _data

var _data: AgentData


func _init(data: AgentData):
	_data = data


func spawn_at(space: SimulatorSpaceData, pos: float, step: int):
	_data.spawn_step = step
	_data.die_step = -1
	_data.pos_history.append(pos)
	_enter(space, step - 1)


func move_to(space: SimulatorSpaceData, step: int):
	_data.pos_history[-1] += space.length
	_enter(space, step)


func die(step: int):
	_data.die_step = step + 1


func _enter(space: SimulatorSpaceData, step: int):
	var moved_index = step - _data.spawn_step + 1
	assert(len(_data.pos_history) - 1 == moved_index)
	_data.space_history[moved_index] = space.id
