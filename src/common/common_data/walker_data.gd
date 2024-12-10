class_name WalkerData

var radius: float

var speed: float

var personal_distance: float
var public_distance: float

var spawn_step: int
var die_step: int

var pos_history: PackedFloat32Array
var bridge_history: Dictionary


static func to_dict(data: WalkerData) -> Dictionary:
	return {
		&"radius": data.radius,
		&"speed": data.speed,
		&"personal_distance": data.personal_distance,
		&"public_distance": data.public_distance,
		&"spawn_step": data.spawn_step,
		&"die_step": data.die_step,
		&"pos_history": data.pos_history,
		&"bridge_history": data.bridge_history,
	}


static func from_dict(dict: Dictionary, script: GDScript = WalkerData) -> WalkerData:
	var data = script.new()
	assert(data is WalkerData)
	data.radius = dict.get(&"radius", NAN)
	data.speed = dict.get(&"speed", NAN)
	data.personal_distance = dict.get(&"personal_distance", NAN)
	data.public_distance = dict.get(&"public_distance", NAN)
	data.spawn_step = dict.get(&"spawn_step", NAN)
	data.die_step = dict.get(&"die_step", NAN)
	data.pos_history = dict.get(&"pos_history", [])
	data.bridge_history = dict.get(&"bridge_history", {})
	return data
