class_name ParameterData
extends DoNotNew

var step_delta: float
var max_step: int
var max_entry_step_gap: int
var random_seed: int

var walker_spawn_rate_before_start: float
var walker_spawn_rate_after_start: float

var walker_spawn_parameters: Array[WalkerData.SpawnParameterData]

var vehicle_spawn_rate_before_start: float
var vehicle_spawn_rate_after_start: float

var vehicle_spawn_parameters: Array[VehicleData.SpawnParameterData]


static func to_dict(data: ParameterData) -> Dictionary:
	return {
		&"step_delta": data.step_delta,
		&"max_step": data.max_step,
		&"max_entry_step_gap": data.max_entry_step_gap,
		&"random_seed": data.random_seed,
		&"walker_spawn_rate_before_start": data.walker_spawn_rate_before_start,
		&"walker_spawn_rate_after_start": data.walker_spawn_rate_after_start,
		&"walker_spawn_parameters": data.walker_spawn_parameters.map(WalkerData.SpawnParameterData.to_dict),
		&"vehicle_spawn_rate_before_start": data.vehicle_spawn_rate_before_start,
		&"vehicle_spawn_rate_after_start": data.vehicle_spawn_rate_after_start,
		&"vehicle_spawn_parameters": data.vehicle_spawn_parameters.map(VehicleData.SpawnParameterData.to_dict),
	}


static func from_dict(dict: Dictionary) -> ParameterData:
	var data = _new(ParameterData)
	data.step_delta = dict.get(&"step_delta", setting.default_step_delta)
	data.max_step = dict.get(&"max_step", setting.default_max_step)
	data.max_entry_step_gap = dict.get(&"max_entry_step_gap", setting.default_max_entry_step_gap)
	data.random_seed = dict.get(&"random_seed", setting.default_random_seed)
	data.walker_spawn_rate_before_start = dict.get(&"walker_spawn_rate_before_start", setting.default_walker_spawn_rate_before_start)
	data.walker_spawn_rate_after_start = dict.get(&"walker_spawn_rate_after_start", setting.default_walker_spawn_rate_after_start)
	data.walker_spawn_parameters.assign(dict.get(&"walker_spawn_parameters", setting.default_walker_spawn_parameters).map(WalkerData.SpawnParameterData.from_dict))
	data.vehicle_spawn_rate_before_start = dict.get(&"vehicle_spawn_rate_before_start", setting.default_vehicle_spawn_rate_before_start)
	data.vehicle_spawn_rate_after_start = dict.get(&"vehicle_spawn_rate_after_start", setting.default_vehicle_spawn_rate_after_start)
	data.vehicle_spawn_parameters.assign(dict.get(&"vehicle_spawn_parameters", setting.default_vehicle_spawn_parameters).map(VehicleData.SpawnParameterData.from_dict))
	return data


static func new_default() -> ParameterData:
	return from_dict({})
