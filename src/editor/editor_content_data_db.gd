class_name EditorContentDataDB

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


static func view(content_dbs: Array[EditorContentDataDB]) -> View:
	var content_dicts: Array[Dictionary]
	for content_db in content_dbs:
		content_dicts.append(content_db._content_dict)

	return View.new(content_dicts)


class View:
	var _content_dicts: Array[Dictionary]


	func _init(content_dicts: Array[Dictionary]):
		_content_dicts = content_dicts


	func has_of(content_id: StringName) -> bool:
		return not _get_content_dict_of(content_id).is_empty()


	func get_of(content_id: StringName) -> ContentData:
		return _get_content_dict_of(content_id)[content_id]


	func _get_content_dict_of(content_id: StringName) -> Dictionary:
		for content_dict in _content_dicts:
			if content_dict.has(content_id):
				return content_dict

		return {}
