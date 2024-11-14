class_name EditorContentDB

signal content_added(content: ContentData)
signal content_removed(content: ContentData)

var _content_dict: Dictionary

var contents: Array[ContentData]:
	get:
		var result: Array[ContentData]
		for content in _content_dict.values():
			result.append(content)
		return result


func add(content: ContentData) -> void:
	_content_dict[content.id] = content
	content_added.emit(content)


func remove(content: ContentData) -> void:
	_content_dict.erase(content.id)
	content_removed.emit(content)


func has_of(content_id: StringName) -> bool:
	return _content_dict.has(content_id)


func get_of(content_id: StringName) -> ContentData:
	return _content_dict[content_id]
