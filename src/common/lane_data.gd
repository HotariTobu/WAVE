class_name LaneData
extends SpaceData

var speed_limit: int
var next_option_dict: Dictionary

@warning_ignore("unused_private_class_variable")
var _next_option_dict: Dictionary:
	get:
		var value = {}
		for lane_id in next_option_dict:
			var option_data = next_option_dict[lane_id]
			value[lane_id] = OptionData.to_dict(option_data)
		return value

	set(value):
		next_option_dict.clear()
		for lane_id in value:
			var option_dict = value[lane_id]
			next_option_dict[lane_id] = OptionData.from_dict(option_dict)


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
	var weight: float

	static func to_dict(data: OptionData) -> Dictionary:
		return {&"weight": data.weight}

	static func from_dict(dict: Dictionary) -> OptionData:
		var data = OptionData.new()
		data.weight = dict.get(&"weight", NAN)
		return data
