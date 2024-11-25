class_name SplitData
extends ContentData

var duration: float
var block_target_ids: Array[StringName]


static func to_dict(data: ContentData) -> Dictionary:
	assert(data is SplitData)
	var dict = super(data)
	dict[&"duration"] = data.duration
	dict[&"block_target_ids"] = data.block_target_ids
	return dict


static func from_dict(dict: Dictionary, script: GDScript = SplitData) -> ContentData:
	var data = super(dict, script)
	assert(data is SplitData)
	data.duration = dict.get(&"duration", setting.default_split_duration)
	data.block_target_ids.assign(dict.get(&"block_target_ids", []))
	return data
