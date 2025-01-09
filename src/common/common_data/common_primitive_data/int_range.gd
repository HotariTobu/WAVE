class_name IntRange

var begin: int
var end: int


static func to_dict(data: IntRange) -> Dictionary:
	return {
		&"begin": data.begin,
		&"end": data.end,
	}


static func from_dict(dict: Dictionary) -> IntRange:
	var data = IntRange.new()
	data.begin = dict.get(&"begin", 0)
	data.end = dict.get(&"end", 0)
	return data
