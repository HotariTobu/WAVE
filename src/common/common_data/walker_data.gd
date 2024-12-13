class_name WalkerData
extends AgentData

var radius: float

var speed: float

var personal_distance: float
var public_distance: float


static func to_dict(data: AgentData) -> Dictionary:
	assert(data is VehicleData)
	var dict = super(data)
	dict[&"radius"] = data.radius
	dict[&"speed"] = data.speed
	dict[&"personal_distance"] = data.personal_distance
	dict[&"public_distance"] = data.public_distance
	return dict


static func from_dict(dict: Dictionary, script: GDScript = VehicleData) -> AgentData:
	var data = super(dict, script)
	assert(data is VehicleData)
	data.radius = dict.get(&"radius", NAN)
	data.speed = dict.get(&"speed", NAN)
	data.personal_distance = dict.get(&"personal_distance", NAN)
	data.public_distance = dict.get(&"public_distance", NAN)
	return data
