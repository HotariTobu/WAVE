class_name EditorContentDB

signal contents_renewed(contents: Array[ContentData])
signal content_added(content: ContentData)
signal content_removed(content: ContentData)

var contents: Array:
	get:
		return _content_dict.values()

	set(new_contents):
		_content_dict.clear()
		for content in new_contents:
			_content_dict[content.id] = content

		var typed_array = Array(new_contents, TYPE_OBJECT, &"RefCounted", ContentData)
		contents_renewed.emit(typed_array)

var _content_dict: Dictionary


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
