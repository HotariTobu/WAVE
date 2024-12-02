class_name VehicleData

var length: float

var high_speed_acceleration: float

var high_speed: float
var max_speed: float

var zero_speed_distance: float
var high_speed_distance: float

var spawn_step: int
var die_step: int

var pos_history: PackedFloat32Array
var lane_history: Dictionary


static func to_dict(data: VehicleData) -> Dictionary:
	return {
		&"length": data.length,
		&"high_speed_acceleration": data.high_speed_acceleration,
		&"high_speed": data.high_speed,
		&"max_speed": data.max_speed,
		&"zero_speed_distance": data.zero_speed_distance,
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
	data.high_speed_acceleration = dict.get(&"high_speed_acceleration", NAN)
	data.high_speed = dict.get(&"high_speed", NAN)
	data.max_speed = dict.get(&"max_speed", NAN)
	data.zero_speed_distance = dict.get(&"zero_speed_distance", NAN)
	data.high_speed_distance = dict.get(&"high_speed_distance", NAN)
	data.spawn_step = dict.get(&"spawn_step", NAN)
	data.die_step = dict.get(&"die_step", NAN)
	data.pos_history = dict.get(&"pos_history", [])
	data.lane_history = dict.get(&"lane_history", {})
	return data
