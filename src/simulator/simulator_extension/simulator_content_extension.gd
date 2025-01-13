class_name SimulatorContentExtension

var id: StringName:
	get:
		return _data.id

var _data: ContentData


func _init(data: ContentData):
	_data = data


func extend(_ext_of: Callable) -> void:
	pass


func _assign_ext_array(self_property: StringName, data_property: StringName, ext_of: Callable) -> void:
	var dst_array = self[self_property] as Array
	var src_array = _data[data_property] as Array
	dst_array.assign(src_array.map(ext_of))
	dst_array.make_read_only()


func _assign_ext_dict(self_property: StringName, data_property: StringName, ext_of: Callable) -> void:
	var dst_dict = self[self_property] as Dictionary
	var src_dict = _data[data_property] as Dictionary
	for content_id in src_dict:
		var key = ext_of.call(content_id)
		var value = src_dict[content_id]
		dst_dict[key] = value
	dst_dict.make_read_only()


static func id_of(ext: SimulatorContentExtension) -> StringName:
	return ext._data.id
