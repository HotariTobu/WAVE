class_name AgentData

var spawn_step: int
var die_step: int

var pos_history: PackedFloat32Array
var space_history: Dictionary


static func to_dict(data: AgentData) -> Dictionary:
	return {
		&"spawn_step": data.spawn_step,
		&"die_step": data.die_step,
		&"pos_history": data.pos_history,
		&"space_history": data.space_history,
	}


static func from_dict(dict: Dictionary, script: GDScript = AgentData) -> AgentData:
	var data = script.new()
	data.spawn_step = dict.get(&"spawn_step", NAN)
	data.die_step = dict.get(&"die_step", NAN)
	data.pos_history = dict.get(&"pos_history", [])
	data.space_history = dict.get(&"space_history", {})
	return data
