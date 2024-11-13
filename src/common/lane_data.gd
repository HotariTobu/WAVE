class_name LaneData
extends SegmentsData

var speed_limit: int = NAN
var next_option_dict: Dictionary = {}

var _next_option_dict: Dictionary:
	get:
		var value = {}
		for vertex_id in next_option_dict:
			var option_data = next_option_dict[vertex_id]
			value[vertex_id] = OptionData.to_dict(option_data)
		return value

	set(value):
		next_option_dict.clear()
		for vertex_id in value:
			var option_dict = value[vertex_id]
			next_option_dict[vertex_id] = OptionData.from_dict(option_dict)


static func to_dict(data: ContentData) -> Dictionary:
	assert(data is LaneData)
	var dict = super(data)
	dict[&"speed_limit"] = data.speed_limit
	dict[&"next_option_dict"] = data._next_option_dict
	return dict


static func from_dict(dict: Dictionary, script: GDScript = LaneData) -> ContentData:
	var data = super(dict, script)
	assert(data is LaneData)
	data.speed_limit = dict.get(&"speed_limit", NAN)
	data._next_option_dict = dict.get(&"next_option_dict", {})
	return data


class OptionData:
	var weight: float = NAN

	static func to_dict(data: OptionData) -> Dictionary:
		return {&"weight": data.weight}

	static func from_dict(dict: Dictionary) -> OptionData:
		var data = OptionData.new()
		data.weight = dict.get(&"weight", NAN)
		return data
