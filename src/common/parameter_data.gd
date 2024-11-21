class_name ParameterData

var step_delta: float
var max_step: int

var vehicle_spawn_before_start: bool
var vehicle_spawn_after_start: bool
var vehicle_spawn_limit: int

static func to_dict(data: ParameterData) -> Dictionary:
	return {
		&"step_delta": data.step_delta,
		&"max_step": data.max_step,
		&"vehicle_spawn_before_start": data.vehicle_spawn_before_start,
		&"vehicle_spawn_after_start": data.vehicle_spawn_after_start,
		&"vehicle_spawn_limit": data.vehicle_spawn_limit,
	}


static func from_dict(dict: Dictionary) -> ParameterData:
	var data = ParameterData.new()
	data.step_delta = dict.get(&"step_delta", NAN)
	data.max_step = dict.get(&"max_step", NAN)
	data.vehicle_spawn_before_start = dict.get(&"vehicle_spawn_before_start", NAN)
	data.vehicle_spawn_after_start = dict.get(&"vehicle_spawn_after_start", NAN)
	data.vehicle_spawn_limit = dict.get(&"vehicle_spawn_limit", NAN)
	return data
