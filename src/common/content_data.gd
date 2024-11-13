class_name ContentData

const NULL_ID = &"null"

var _id: StringName = NULL_ID


static func id_of(data: ContentData) -> StringName:
	if data._id == NULL_ID:
		data._id = UUID.v7()

	return data._id


static func to_dict(data: ContentData) -> Dictionary:
	return {
		&"id": id_of(data),
	}


static func from_dict(dict: Dictionary, script: GDScript = ContentData) -> ContentData:
	var data = script.new()
	assert(data is ContentData)
	data._id = dict.get(&"id", NULL_ID)
	return data
