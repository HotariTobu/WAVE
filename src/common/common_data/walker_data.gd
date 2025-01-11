class_name WalkerData
extends AgentData

var radius: float

var speed: float
var overtake_speed: float

var personal_distance: float
var public_distance: float


static func to_dict(data: AgentData) -> Dictionary:
	assert(data is WalkerData)
	var dict = super(data)
	dict[&"radius"] = data.radius
	dict[&"speed"] = data.speed
	dict[&"overtake_speed"] = data.overtake_speed
	dict[&"personal_distance"] = data.personal_distance
	dict[&"public_distance"] = data.public_distance
	return dict


static func from_dict(dict: Dictionary, script: GDScript = WalkerData) -> AgentData:
	var data = super(dict, script)
	assert(data is WalkerData)
	data.radius = dict.get(&"radius", NAN)
	data.speed = dict.get(&"speed", NAN)
	data.overtake_speed = dict.get(&"overtake_speed", NAN)
	data.personal_distance = dict.get(&"personal_distance", NAN)
	data.public_distance = dict.get(&"public_distance", NAN)
	return data


class SpawnParameterData:
	var weight: float

	var radius: float

	var speed_range: FloatRange
	var speed_mean: float
	var overtake_speed_range: FloatRange
	var overtake_speed_mean: float

	var personal_distance_range: FloatRange
	var personal_distance_mean: float
	var public_distance_range: FloatRange
	var public_distance_mean: float

	static func to_dict(data: SpawnParameterData) -> Dictionary:
		return {
			&"weight": data.weight,
			&"radius": data.radius,
			&"speed_range": FloatRange.to_dict(data.speed_range),
			&"speed_mean": data.speed_mean,
			&"overtake_speed_range": FloatRange.to_dict(data.overtake_speed_range),
			&"overtake_speed_mean": data.overtake_speed_mean,
			&"personal_distance_range": FloatRange.to_dict(data.personal_distance_range),
			&"personal_distance_mean": data.personal_distance_mean,
			&"public_distance_range": FloatRange.to_dict(data.public_distance_range),
			&"public_distance_mean": data.public_distance_mean,
		}

	static func from_dict(dict: Dictionary) -> SpawnParameterData:
		var data = SpawnParameterData.new()
		data.weight = dict.get(&"weight", NAN)
		data.radius = dict.get(&"radius", NAN)
		data.speed_range = FloatRange.from_dict(dict.get(&"speed_range", {}))
		data.speed_mean = dict.get(&"speed_mean", NAN)
		data.overtake_speed_range = FloatRange.from_dict(dict.get(&"overtake_speed_range", {}))
		data.overtake_speed_mean = dict.get(&"overtake_speed_mean", NAN)
		data.personal_distance_range = FloatRange.from_dict(dict.get(&"personal_distance_range", {}))
		data.personal_distance_mean = dict.get(&"personal_distance_mean", NAN)
		data.public_distance_range = FloatRange.from_dict(dict.get(&"public_distance_range", {}))
		data.public_distance_mean = dict.get(&"public_distance_mean", NAN)
		return data
