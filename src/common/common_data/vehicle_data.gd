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
