class_name VehicleData

var length: float

var relative_speed: float
var max_speed: float

var min_following_distance: float
var max_following_distance: float


static func to_dict(data: ContentData) -> Dictionary:
	return {
		&"length": data.length,
		&"relative_speed": data.relative_speed,
		&"max_speed": data.max_speed,
		&"min_following_distance": data.min_following_distance,
		&"max_following_distance": data.max_following_distance,
	}


static func from_dict(dict: Dictionary, script: GDScript = ContentData) -> ContentData:
	var data = script.new()
	assert(data is ContentData)
	data.length = dict.get(&"length", NAN)
	data.relative_speed = dict.get(&"relative_speed", NAN)
	data.max_speed = dict.get(&"max_speed", NAN)
	data.min_following_distance = dict.get(&"min_following_distance", NAN)
	data.max_following_distance = dict.get(&"max_following_distance", NAN)
	return data
