class_name ContentData

const NULL_ID = &"null"

var _id: StringName = NULL_ID

var id: StringName:
	get:
		if _id == NULL_ID:
			_id = UUID.v7()

		return _id


static func id_of(data: ContentData) -> StringName:
	return data.id


static func to_dict(data: ContentData) -> Dictionary:
	return {
		&"id": id_of(data),
	}


static func from_dict(dict: Dictionary, script: GDScript = ContentData) -> ContentData:
	var data = script.new()
	assert(data is ContentData)
	data._id = dict.get(&"id", NULL_ID)
	return data
