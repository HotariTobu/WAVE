class_name SpaceData
extends SegmentsData

var block_target_ids: Array[StringName]

static func to_dict(data: ContentData) -> Dictionary:
	assert(data is SpaceData)
	var dict = super(data)
	dict[&"block_target_ids"] = data.block_target_ids
	return dict


static func from_dict(dict: Dictionary, script: GDScript = SpaceData) -> ContentData:
	var data = super(dict, script)
	assert(data is SpaceData)
	data.block_target_ids.assign(dict.get(&"block_target_ids", []))
	return data
