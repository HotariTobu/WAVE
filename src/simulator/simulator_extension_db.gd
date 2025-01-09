class_name SimulatorExtensionDB

var _content_id_group_name_dict: Dictionary
var _content_id_data_dict: Dictionary

var _content_id_extension_dict: Dictionary
var _group_name_extensions_dict: Dictionary


func _init(network: NetworkData):
	for group_name in NetworkData.group_names:
		var contents = network[group_name]

		for content in contents:
			_content_id_group_name_dict[content.id] = group_name
			_content_id_data_dict[content.id] = content

	_content_id_group_name_dict.make_read_only()
	_content_id_data_dict.make_read_only()

	for group_name in NetworkData.group_names:
		var contents = network[group_name] as Array
		var extensions: Array

		for content in contents:
			var extension = _extension_of(content.id)
			extension.extend(_extension_of)
			extensions.append(extension)

		extensions.make_read_only()
		_group_name_extensions_dict[group_name] = extensions

	_content_id_extension_dict.make_read_only()
	_group_name_extensions_dict.make_read_only()


func _get(group_name: StringName):
	return _group_name_extensions_dict[group_name]


func _extension_of(content_id: StringName) -> SimulatorContentExtension:
	if _content_id_extension_dict.has(content_id):
		return _content_id_extension_dict[content_id]

	var group_name = _content_id_group_name_dict[content_id]
	var script = SimulatorScriptDict.ext[group_name] as GDScript
	var content = _content_id_data_dict[content_id]
	var extension = script.new(content)
	_content_id_extension_dict[content_id] = extension
	return extension
