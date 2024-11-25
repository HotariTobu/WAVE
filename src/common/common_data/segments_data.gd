class_name SegmentsData
extends ContentData

var vertex_ids: Array[StringName]


static func to_dict(data: ContentData) -> Dictionary:
	assert(data is SegmentsData)
	var dict = super(data)
	dict[&"vertex_ids"] = data.vertex_ids
	return dict


static func from_dict(dict: Dictionary, script: GDScript = SegmentsData) -> ContentData:
	var data = super(dict, script)
	assert(data is SegmentsData)
	data.vertex_ids.assign(dict.get(&"vertex_ids", []))
	return data
