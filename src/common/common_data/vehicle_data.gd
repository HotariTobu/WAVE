class_name VehicleData
extends AgentData

var length: float

var high_speed_acceleration: float

var high_speed: float
var max_speed: float

var zero_speed_distance: float
var half_speed_distance: float
var high_speed_distance: float


static func to_dict(data: AgentData) -> Dictionary:
	assert(data is VehicleData)
	var dict = super(data)
	dict[&"length"] = data.length
	dict[&"high_speed_acceleration"] = data.high_speed_acceleration
	dict[&"high_speed"] = data.high_speed
	dict[&"max_speed"] = data.max_speed
	dict[&"zero_speed_distance"] = data.zero_speed_distance
	dict[&"half_speed_distance"] = data.half_speed_distance
	dict[&"high_speed_distance"] = data.high_speed_distance
	return dict


static func from_dict(dict: Dictionary, script: GDScript = VehicleData) -> AgentData:
	var data = super(dict, script)
	assert(data is VehicleData)
	data.length = dict.get(&"length", NAN)
	data.high_speed_acceleration = dict.get(&"high_speed_acceleration", NAN)
	data.high_speed = dict.get(&"high_speed", NAN)
	data.max_speed = dict.get(&"max_speed", NAN)
	data.zero_speed_distance = dict.get(&"zero_speed_distance", NAN)
	data.half_speed_distance = dict.get(&"half_speed_distance", NAN)
	data.high_speed_distance = dict.get(&"high_speed_distance", NAN)
	return data


class SpawnParameterData:
	var weight: float

	var length: float

	var high_speed_acceleration_range: FloatRange
	var high_speed_acceleration_mean: float

	var high_speed_range: FloatRange
	var high_speed_mean: float
	var max_speed_range: FloatRange
	var max_speed_mean: float

	var zero_speed_distance_range: FloatRange
	var zero_speed_distance_mean: float
	var half_speed_distance_range: FloatRange
	var half_speed_distance_mean: float
	var high_speed_distance_range: FloatRange
	var high_speed_distance_mean: float

	static func to_dict(data: SpawnParameterData) -> Dictionary:
		return {
			&"weight": data.weight,
			&"length": data.length,
			&"high_speed_acceleration_range": FloatRange.to_dict(data.high_speed_acceleration_range),
			&"high_speed_acceleration_mean": data.high_speed_acceleration_mean,
			&"high_speed_range": FloatRange.to_dict(data.high_speed_range),
			&"high_speed_mean": data.high_speed_mean,
			&"max_speed_range": FloatRange.to_dict(data.max_speed_range),
			&"max_speed_mean": data.max_speed_mean,
			&"zero_speed_distance_range": FloatRange.to_dict(data.zero_speed_distance_range),
			&"zero_speed_distance_mean": data.zero_speed_distance_mean,
			&"half_speed_distance_range": FloatRange.to_dict(data.half_speed_distance_range),
			&"half_speed_distance_mean": data.half_speed_distance_mean,
			&"high_speed_distance_range": FloatRange.to_dict(data.high_speed_distance_range),
			&"high_speed_distance_mean": data.high_speed_distance_mean,
		}

	static func from_dict(dict: Dictionary) -> SpawnParameterData:
		var data = SpawnParameterData.new()
		data.weight = dict.get(&"weight", NAN)
		data.length = dict.get(&"length", NAN)
		data.high_speed_acceleration_range = FloatRange.from_dict(dict.get(&"high_speed_acceleration_range", {}))
		data.high_speed_acceleration_mean = dict.get(&"high_speed_acceleration_mean", NAN)
		data.high_speed_range = FloatRange.from_dict(dict.get(&"high_speed_range", {}))
		data.high_speed_mean = dict.get(&"high_speed_mean", NAN)
		data.max_speed_range = FloatRange.from_dict(dict.get(&"max_speed_range", {}))
		data.max_speed_mean = dict.get(&"max_speed_mean", NAN)
		data.zero_speed_distance_range = FloatRange.from_dict(dict.get(&"zero_speed_distance_range", {}))
		data.zero_speed_distance_mean = dict.get(&"zero_speed_distance_mean", NAN)
		data.half_speed_distance_range = FloatRange.from_dict(dict.get(&"half_speed_distance_range", {}))
		data.half_speed_distance_mean = dict.get(&"half_speed_distance_mean", NAN)
		data.high_speed_distance_range = FloatRange.from_dict(dict.get(&"high_speed_distance_range", {}))
		data.high_speed_distance_mean = dict.get(&"high_speed_distance_mean", NAN)
		return data
