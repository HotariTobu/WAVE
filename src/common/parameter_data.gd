class_name ParameterData

var step_delta: float
var max_step: int

var vehicle_spawn_before_start: bool
var vehicle_spawn_after_start: bool
var vehicle_spawn_limit: int

var vehicle_length_options: Array[RandomOption]

var vehicle_relative_speed_range: IntRange
var vehicle_relative_speed_mean: int
var vehicle_max_speed_range: IntRange
var vehicle_max_speed_mean: int
var vehicle_min_following_distance_range: IntRange
var vehicle_min_following_distance_mean: int
var vehicle_max_following_distance_range: IntRange
var vehicle_max_following_distance_mean: int


static func to_dict(data: ParameterData) -> Dictionary:
	return {
		&"step_delta": data.step_delta,
		&"max_step": data.max_step,
		&"vehicle_spawn_before_start": data.vehicle_spawn_before_start,
		&"vehicle_spawn_after_start": data.vehicle_spawn_after_start,
		&"vehicle_spawn_limit": data.vehicle_spawn_limit,
		&"vehicle_length_options": data.vehicle_length_options.map(RandomOption.to_dict),
		&"vehicle_relative_speed_range": IntRange.to_dict(data.vehicle_relative_speed_range),
		&"vehicle_relative_speed_mean": data.vehicle_relative_speed_mean,
		&"vehicle_max_speed_range": IntRange.to_dict(data.vehicle_max_speed_range),
		&"vehicle_max_speed_mean": data.vehicle_max_speed_mean,
		&"vehicle_min_following_distance_range": IntRange.to_dict(data.vehicle_min_following_distance_range),
		&"vehicle_min_following_distance_mean": data.vehicle_min_following_distance_mean,
		&"vehicle_max_following_distance_range": IntRange.to_dict(data.vehicle_max_following_distance_range),
		&"vehicle_max_following_distance_mean": data.vehicle_max_following_distance_mean,
	}


static func from_dict(dict: Dictionary) -> ParameterData:
	var data = ParameterData.new()
	data.step_delta = dict.get(&"step_delta", NAN)
	data.max_step = dict.get(&"max_step", NAN)
	data.vehicle_spawn_before_start = dict.get(&"vehicle_spawn_before_start", NAN)
	data.vehicle_spawn_after_start = dict.get(&"vehicle_spawn_after_start", NAN)
	data.vehicle_spawn_limit = dict.get(&"vehicle_spawn_limit", NAN)
	data.vehicle_length_options.assign(dict.get(&"vehicle_length_options", NAN).map(RandomOption.from_dict))
	data.vehicle_relative_speed_range = IntRange.from_dict(dict.get(&"vehicle_relative_speed_range", NAN))
	data.vehicle_relative_speed_mean = dict.get(&"vehicle_relative_speed_mean", NAN)
	data.vehicle_max_speed_range = IntRange.from_dict(dict.get(&"vehicle_max_speed_range", NAN))
	data.vehicle_max_speed_mean = dict.get(&"vehicle_max_speed_mean", NAN)
	data.vehicle_min_following_distance_range = IntRange.from_dict(dict.get(&"vehicle_min_following_distance_range", NAN))
	data.vehicle_min_following_distance_mean = dict.get(&"vehicle_min_following_distance_mean", NAN)
	data.vehicle_max_following_distance_range = IntRange.from_dict(dict.get(&"vehicle_max_following_distance_range", NAN))
	data.vehicle_max_following_distance_mean = dict.get(&"vehicle_max_following_distance_mean", NAN)
	return data


class RandomOption:
	var value: Variant
	var weight: float

	func _init(_value: Variant, _weight: float):
		value = _value
		weight = _weight

	static func to_dict(data: RandomOption) -> Dictionary:
		return {
			&"value": data.value,
			&"weight": data.weight,
		}

	static func from_dict(dict: Dictionary) -> RandomOption:
		return RandomOption.new(dict[&"value"], dict[&"weight"])


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
		return IntRange.new(dict[&"begin"], dict[&"end"])
