class_name SpaceData
extends SegmentsData

var block_target_id_set: Set

static func to_dict(data: ContentData) -> Dictionary:
	assert(data is SpaceData)
	var dict = super(data)
	dict[&"block_target_id_set"] = data.block_target_id_set.to_array()
	return dict


static func from_dict(dict: Dictionary, script: GDScript = SpaceData) -> ContentData:
	var data = super(dict, script)
	assert(data is SpaceData)
	data.block_target_id_set = Set.from_array(dict.get(&"block_target_id_set", []))
	return data
