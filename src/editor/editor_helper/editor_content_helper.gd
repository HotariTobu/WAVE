class_name EditorContentHelper


static func replace_id(_content: ContentData, _new_id_of: Callable) -> void:
	pass


static func _replace_array_ids(property: StringName, content: ContentData, new_id_of: Callable) -> void:
	content[property].assign(content[property].map(new_id_of).filter(_not_null))


static func _replace_dict_ids(property: StringName, content: ContentData, new_id_of: Callable) -> void:
	var old_dict = content[property]
	var new_dict: Dictionary

	for old_id in old_dict:
		var new_id = new_id_of.call(old_id)
		if new_id == null:
			continue

		var value = old_dict[old_id]
		new_dict[new_id] = value

	content[property] = new_dict


static func _not_null(value: Variant) -> bool:
	return value != null
