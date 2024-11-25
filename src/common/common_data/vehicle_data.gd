class_name VehicleData

var length: float

var max_acceleration: float

var base_speed: float
var max_speed: float

var low_speed_distance: float
var high_speed_distance: float

var spawn_step: int
var die_step: int

var pos_history: PackedFloat32Array
var lane_history: Dictionary


static func to_dict(data: VehicleData) -> Dictionary:
	return {
		&"length": data.length,
		&"max_acceleration": data.max_acceleration,
		&"base_speed": data.base_speed,
		&"max_speed": data.max_speed,
		&"low_speed_distance": data.low_speed_distance,
		&"high_speed_distance": data.high_speed_distance,
		&"spawn_step": data.spawn_step,
		&"die_step": data.die_step,
		&"pos_history": data.pos_history,
		&"lane_history": data.lane_history,
	}


static func from_dict(dict: Dictionary, script: GDScript = VehicleData) -> VehicleData:
	var data = script.new()
	assert(data is VehicleData)
	data.length = dict.get(&"length", NAN)
	data.max_acceleration = dict.get(&"max_acceleration", NAN)
	data.base_speed = dict.get(&"base_speed", NAN)
	data.max_speed = dict.get(&"max_speed", NAN)
	data.low_speed_distance = dict.get(&"low_speed_distance", NAN)
	data.high_speed_distance = dict.get(&"high_speed_distance", NAN)
	data.spawn_step = dict.get(&"spawn_step", NAN)
	data.die_step = dict.get(&"die_step", NAN)
	data.pos_history = dict.get(&"pos_history", [])
	data.lane_history = dict.get(&"lane_history", {})
	return data
