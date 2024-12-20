class_name WalkerData
extends AgentData

var radius: float

var desired_speed: float
var overtake_speed: float

var personal_distance: float
var public_distance: float


static func to_dict(data: AgentData) -> Dictionary:
	assert(data is VehicleData)
	var dict = super(data)
	dict[&"radius"] = data.radius
	dict[&"desired_speed"] = data.desired_speed
	dict[&"overtake_speed"] = data.overtake_speed
	dict[&"personal_distance"] = data.personal_distance
	dict[&"public_distance"] = data.public_distance
	return dict


static func from_dict(dict: Dictionary, script: GDScript = VehicleData) -> AgentData:
	var data = super(dict, script)
	assert(data is VehicleData)
	data.radius = dict.get(&"radius", NAN)
	data.desired_speed = dict.get(&"desired_speed", NAN)
	data.overtake_speed = dict.get(&"overtake_speed", NAN)
	data.personal_distance = dict.get(&"personal_distance", NAN)
	data.public_distance = dict.get(&"public_distance", NAN)
	return data


class SpawnParameterData:
	var weight: float

	var radius: float

	var desired_speed_range: FloatRange
	var desired_speed_mean: float
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
			&"desired_speed_range": FloatRange.to_dict(data.desired_speed_range),
			&"desired_speed_mean": data.desired_speed_mean,
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
		data.desired_speed_range = FloatRange.from_dict(dict.get(&"desired_speed_range", {}))
		data.desired_speed_mean = dict.get(&"desired_speed_mean", NAN)
		data.overtake_speed_range = FloatRange.from_dict(dict.get(&"overtake_speed_range", {}))
		data.overtake_speed_mean = dict.get(&"overtake_speed_mean", NAN)
		data.personal_distance_range = FloatRange.from_dict(dict.get(&"personal_distance_range", {}))
		data.personal_distance_mean = dict.get(&"personal_distance_mean", NAN)
		data.public_distance_range = FloatRange.from_dict(dict.get(&"public_distance_range", {}))
		data.public_distance_mean = dict.get(&"public_distance_mean", NAN)
		return data
