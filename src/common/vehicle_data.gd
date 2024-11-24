class_name VehicleData

var length: float

var max_acceleration: float

var condition_speed: float
var relative_speed: float
var max_speed: float

var min_following_distance: float
var max_following_distance: float

var pos_history: PackedFloat32Array
var lane_history: Dictionary


static func to_dict(data: VehicleData) -> Dictionary:
	return {
		&"length": data.length,
		&"max_acceleration": data.max_acceleration,
		&"condition_speed": data.condition_speed,
		&"relative_speed": data.relative_speed,
		&"max_speed": data.max_speed,
		&"min_following_distance": data.min_following_distance,
		&"max_following_distance": data.max_following_distance,
		&"pos_history": data.pos_history,
		&"lane_history": data.lane_history,
	}


static func from_dict(dict: Dictionary, script: GDScript = VehicleData) -> VehicleData:
	var data = script.new()
	assert(data is VehicleData)
	data.length = dict.get(&"length", NAN)
	data.max_acceleration = dict.get(&"max_acceleration", NAN)
	data.condition_speed = dict.get(&"condition_speed", NAN)
	data.relative_speed = dict.get(&"relative_speed", NAN)
	data.max_speed = dict.get(&"max_speed", NAN)
	data.min_following_distance = dict.get(&"min_following_distance", NAN)
	data.max_following_distance = dict.get(&"max_following_distance", NAN)
	data.pos_history = dict.get(&"pos_history", [])
	data.lane_history = dict.get(&"lane_history", {})
	return data
