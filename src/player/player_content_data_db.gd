class_name PlayerContentDataDB

var _content_dict: Dictionary


func _init(network: NetworkData):
	for group_name in NetworkData.group_names:
		var contents = network[group_name]

		for content in contents:
			_content_dict[content.id] = content

	_content_dict.make_read_only()


func data_of(content_id: StringName) -> ContentData:
	return _content_dict[content_id]
