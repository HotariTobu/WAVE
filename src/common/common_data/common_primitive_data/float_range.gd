class_name FloatRange

var begin: float
var end: float


static func to_dict(data: FloatRange) -> Dictionary:
	return {
		&"begin": data.begin,
		&"end": data.end,
	}


static func from_dict(dict: Dictionary) -> FloatRange:
	var data = FloatRange.new()
	data.begin = dict.get(&"begin", NAN)
	data.end = dict.get(&"end", NAN)
	return data
