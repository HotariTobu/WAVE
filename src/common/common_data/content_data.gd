class_name ContentData
extends DoNotNew

var id: StringName


static func id_of(data: ContentData) -> StringName:
	return data.id


static func to_dict(data: ContentData) -> Dictionary:
	return {
		&"id": data.id,
	}


static func from_dict(dict: Dictionary, script: GDScript = ContentData) -> ContentData:
	var data = _new(script)
	assert(data is ContentData)
	data.id = dict.get(&"id", UUID.v7())
	return data
