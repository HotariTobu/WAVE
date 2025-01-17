class_name StoplightData
extends VertexData

var offset: float
var split_ids: Array[StringName]


static func to_dict(data: ContentData) -> Dictionary:
	assert(data is StoplightData)
	var dict = super(data)
	dict[&"offset"] = data.offset
	dict[&"split_ids"] = data.split_ids
	return dict


static func from_dict(dict: Dictionary, script: GDScript = StoplightData) -> ContentData:
	var data = super(dict, script)
	assert(data is StoplightData)
	data.offset = dict.get(&"offset", setting.default_stoplight_offset)
	data.split_ids.assign(dict.get(&"split_ids", []))
	return data


static func new_default() -> ContentData:
	return from_dict({})
