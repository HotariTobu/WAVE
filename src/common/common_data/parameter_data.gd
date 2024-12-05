class_name ParameterData

var step_delta: float
var max_step: int

var random_seed: int

var vehicle_spawn_before_start: bool
var vehicle_spawn_after_start: bool
var vehicle_spawn_rate: float

var vehicle_length_options: Array[RandomOption]

var vehicle_high_speed_acceleration_range: IntRange
var vehicle_high_speed_acceleration_mean: int

var vehicle_high_speed_range: IntRange
var vehicle_high_speed_mean: int
var vehicle_max_speed_range: IntRange
var vehicle_max_speed_mean: int

var vehicle_zero_speed_distance_range: IntRange
var vehicle_zero_speed_distance_mean: int
var vehicle_half_speed_distance_range: IntRange
var vehicle_half_speed_distance_mean: int
var vehicle_high_speed_distance_range: IntRange
var vehicle_high_speed_distance_mean: int


static func to_dict(data: ParameterData) -> Dictionary:
	return {
		&"step_delta": data.step_delta,
		&"max_step": data.max_step,
		&"random_seed": data.random_seed,
		&"vehicle_spawn_before_start": data.vehicle_spawn_before_start,
		&"vehicle_spawn_after_start": data.vehicle_spawn_after_start,
		&"vehicle_spawn_rate": data.vehicle_spawn_rate,
		&"vehicle_length_options": data.vehicle_length_options.map(RandomOption.to_dict),
		&"vehicle_high_speed_acceleration_range": IntRange.to_dict(data.vehicle_high_speed_acceleration_range),
		&"vehicle_high_speed_acceleration_mean": data.vehicle_high_speed_acceleration_mean,
		&"vehicle_high_speed_range": IntRange.to_dict(data.vehicle_high_speed_range),
		&"vehicle_high_speed_mean": data.vehicle_high_speed_mean,
		&"vehicle_max_speed_range": IntRange.to_dict(data.vehicle_max_speed_range),
		&"vehicle_max_speed_mean": data.vehicle_max_speed_mean,
		&"vehicle_zero_speed_distance_range": IntRange.to_dict(data.vehicle_zero_speed_distance_range),
		&"vehicle_zero_speed_distance_mean": data.vehicle_zero_speed_distance_mean,
		&"vehicle_half_speed_distance_range": IntRange.to_dict(data.vehicle_half_speed_distance_range),
		&"vehicle_half_speed_distance_mean": data.vehicle_half_speed_distance_mean,
		&"vehicle_high_speed_distance_range": IntRange.to_dict(data.vehicle_high_speed_distance_range),
		&"vehicle_high_speed_distance_mean": data.vehicle_high_speed_distance_mean,
	}


static func from_dict(dict: Dictionary) -> ParameterData:
	var data = ParameterData.new()
	data.step_delta = dict.get(&"step_delta", setting.default_step_delta)
	data.max_step = dict.get(&"max_step", setting.default_max_step)
	data.random_seed = dict.get(&"random_seed", setting.default_random_seed)
	data.vehicle_spawn_before_start = dict.get(&"vehicle_spawn_before_start", setting.default_vehicle_spawn_before_start)
	data.vehicle_spawn_after_start = dict.get(&"vehicle_spawn_after_start", setting.default_vehicle_spawn_after_start)
	data.vehicle_spawn_rate = dict.get(&"vehicle_spawn_rate", setting.default_vehicle_spawn_rate)
	data.vehicle_length_options.assign(dict.get(&"vehicle_length_options", setting.default_vehicle_length_options).map(RandomOption.from_dict))
	data.vehicle_high_speed_acceleration_range = IntRange.from_dict(dict.get(&"vehicle_high_speed_acceleration_range", setting.default_vehicle_high_speed_acceleration_range))
	data.vehicle_high_speed_acceleration_mean = dict.get(&"vehicle_high_speed_acceleration_mean", setting.default_vehicle_high_speed_acceleration_mean)
	data.vehicle_high_speed_range = IntRange.from_dict(dict.get(&"vehicle_high_speed_range", setting.default_vehicle_high_speed_range))
	data.vehicle_high_speed_mean = dict.get(&"vehicle_high_speed_mean", setting.default_vehicle_high_speed_mean)
	data.vehicle_max_speed_range = IntRange.from_dict(dict.get(&"vehicle_max_speed_range", setting.default_vehicle_max_speed_range))
	data.vehicle_max_speed_mean = dict.get(&"vehicle_max_speed_mean", setting.default_vehicle_max_speed_mean)
	data.vehicle_zero_speed_distance_range = IntRange.from_dict(dict.get(&"vehicle_zero_speed_distance_range", setting.default_vehicle_zero_speed_distance_range))
	data.vehicle_zero_speed_distance_mean = dict.get(&"vehicle_zero_speed_distance_mean", setting.default_vehicle_zero_speed_distance_mean)
	data.vehicle_half_speed_distance_range = IntRange.from_dict(dict.get(&"vehicle_half_speed_distance_range", setting.default_vehicle_half_speed_distance_range))
	data.vehicle_half_speed_distance_mean = dict.get(&"vehicle_half_speed_distance_mean", setting.default_vehicle_half_speed_distance_mean)
	data.vehicle_high_speed_distance_range = IntRange.from_dict(dict.get(&"vehicle_high_speed_distance_range", setting.default_vehicle_high_speed_distance_range))
	data.vehicle_high_speed_distance_mean = dict.get(&"vehicle_high_speed_distance_mean", setting.default_vehicle_high_speed_distance_mean)
	return data


class RandomOption:
	var value: Variant
	var weight: float

	func _init(_value: Variant, _weight: float):
		value = _value
		weight = _weight

	static func value_of(data: RandomOption) -> Variant:
		return data.value

	static func weight_of(data: RandomOption) -> float:
		return data.weight

	static func to_dict(data: RandomOption) -> Dictionary:
		return {
			&"value": data.value,
			&"weight": data.weight,
		}

	static func from_dict(dict: Dictionary) -> RandomOption:
		return RandomOption.new(dict.get(&"value", NAN), dict.get(&"weight", NAN))


class IntRange:
	var begin: int
	var end: int

	func _init(_begin: int, _end: int):
		begin = _begin
		end = _end

	static func to_dict(data: IntRange) -> Dictionary:
		return {
			&"begin": data.begin,
			&"end": data.end,
		}

	static func from_dict(dict: Dictionary) -> IntRange:
		return IntRange.new(dict.get(&"begin", 0), dict.get(&"end", 0))
