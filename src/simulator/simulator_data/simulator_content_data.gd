class_name SimulatorContentData

var id: StringName


func assign(content: ContentData, _data_of: Callable) -> void:
	id = content.id


func assign_array(self_property: StringName, base_array: Array, data_of: Callable) -> void:
	var array = self[self_property] as Array
	array.assign(base_array.map(data_of))
	array.make_read_only()


func assign_dict(self_property: StringName, base_dict: Dictionary, data_of: Callable) -> void:
	var dict = self[self_property] as Dictionary
	for base_key in base_dict:
		var key = data_of.call(base_key)
		var value = base_dict[base_key]
		dict[key] = value
	dict.make_read_only()
