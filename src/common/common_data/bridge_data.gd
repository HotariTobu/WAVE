class_name BridgeData
extends SpaceData

var traffic: float
var forward_rate: float
var width_limit: int
var prev_option_dict: Dictionary
var next_option_dict: Dictionary

@warning_ignore("unused_private_class_variable")
var _prev_option_dict: Dictionary:
	get:
		var value = {}
		for bridge_id in prev_option_dict:
			var option_data = prev_option_dict[bridge_id]
			value[bridge_id] = OptionData.to_dict(option_data)
		return value

	set(value):
		prev_option_dict.clear()
		for bridge_id in value:
			var option_dict = value[bridge_id]
			prev_option_dict[bridge_id] = OptionData.from_dict(option_dict)

@warning_ignore("unused_private_class_variable")
var _next_option_dict: Dictionary:
	get:
		var value = {}
		for bridge_id in next_option_dict:
			var option_data = next_option_dict[bridge_id]
			value[bridge_id] = OptionData.to_dict(option_data)
		return value

	set(value):
		next_option_dict.clear()
		for bridge_id in value:
			var option_dict = value[bridge_id]
			next_option_dict[bridge_id] = OptionData.from_dict(option_dict)


static func to_dict(data: ContentData) -> Dictionary:
	assert(data is BridgeData)
	var dict = super(data)
	dict[&"traffic"] = data.traffic
	dict[&"forward_rate"] = data.forward_rate
	dict[&"width_limit"] = data.width_limit
	dict[&"prev_option_dict"] = data._prev_option_dict
	dict[&"next_option_dict"] = data._next_option_dict
	return dict


static func from_dict(dict: Dictionary, script: GDScript = BridgeData) -> ContentData:
	var data = super(dict, script)
	assert(data is BridgeData)
	data.traffic = dict.get(&"traffic", setting.default_bridge_traffic)
	data.forward_rate = dict.get(&"forward_rate", setting.default_bridge_forward_rate)
	data.width_limit = dict.get(&"width_limit", setting.default_bridge_width_limit)
	data._prev_option_dict = dict.get(&"prev_option_dict", {})
	data._next_option_dict = dict.get(&"next_option_dict", {})
	return data


static func new_default() -> ContentData:
	return from_dict({})


class OptionData:
	extends DoNotNew

	var weight: float

	static func to_dict(data: OptionData) -> Dictionary:
		return {&"weight": data.weight}

	static func from_dict(dict: Dictionary) -> OptionData:
		var data = _new(OptionData)
		data.weight = dict.get(&"weight", setting.default_bridge_option_weight)
		return data

	static func new_default() -> OptionData:
		return from_dict({})
