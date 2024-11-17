class_name EditorContentDataDB

var groups: Array[Group]:
	get:
		return Array(_group_dict.values(), TYPE_OBJECT, &"RefCounted", Group)

var group_names: Array[StringName]:
	get:
		return Array(_group_dict.keys(), TYPE_STRING_NAME, &"", null)

var _group_dict: Dictionary
var _group_name_dict: Dictionary


func _init(group_name_list: Array):
	for group_name in group_name_list:
		_group_dict[group_name] = Group.new(group_name, _group_name_dict)

	_group_dict.make_read_only()

func get_group(group_name: StringName) -> Group:
	return _group_dict[group_name]


func group_of(content_id: StringName) -> Group:
	var group_name = _group_name_dict[content_id]
	return _group_dict[group_name]


func group_name_of(content_id: StringName) -> StringName:
	return _group_name_dict[content_id]


func add(group_name: StringName, content: ContentData) -> void:
	var group = _group_dict[group_name] as Group
	group._content_dict[content.id] = content
	_group_name_dict[content.id] = group_name
	group.content_added.emit(content)


func remove(group_name: StringName, content: ContentData) -> void:
	var group = _group_dict[group_name] as Group
	group._content_dict.erase(content.id)
	_group_name_dict.erase(content.id)
	group.content_removed.emit(content)


func has_of(content_id: StringName) -> bool:
	return _group_name_dict.has(content_id)


func data_of(content_id: StringName) -> ContentData:
	var group_name = _group_name_dict[content_id]
	var group = _group_dict[group_name] as Group
	return group._content_dict[content_id]


class Group:
	signal contents_renewed(contents: Array[ContentData])
	signal content_added(content: ContentData)
	signal content_removed(content: ContentData)

	var name: StringName:
		get:
			return _name

	var contents: Array:
		get:
			return _content_dict.values()

		set(new_contents):
			for content_id in _content_dict:
				_group_name_dict.erase(content_id)

			_content_dict.clear()

			for content in new_contents:
				_content_dict[content.id] = content
				_group_name_dict[content.id] = _name

			var typed_array = Array(new_contents, TYPE_OBJECT, &"RefCounted", ContentData)
			contents_renewed.emit(typed_array)

	var _name: StringName
	var _group_name_dict: Dictionary

	var _content_dict: Dictionary

	func _init(group_name: StringName, group_name_dict: Dictionary):
		_name = group_name
		_group_name_dict = group_name_dict

	func add(content: ContentData) -> void:
		assert(not _content_dict.has(content.id))
		_content_dict[content.id] = content
		_group_name_dict[content.id] = _name
		content_added.emit(content)

	func remove(content: ContentData) -> void:
		assert(_content_dict.has(content.id))
		_content_dict.erase(content.id)
		_group_name_dict.erase(content.id)
		content_removed.emit(content)

	func has_of(content_id: StringName) -> bool:
		return _content_dict.has(content_id)

	func data_of(content_id: StringName) -> ContentData:
		return _content_dict[content_id]
