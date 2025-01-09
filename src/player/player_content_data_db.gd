class_name PlayerContentDataDB

var _player_content_dict: Dictionary


func _init(network: NetworkData):
	var content_dict: Dictionary

	for group_name in NetworkData.group_names:
		var contents = network[group_name] as Array

		for content in contents:
			content_dict[content.id] = content

	content_dict.make_read_only()
	var data_of = func(content_id: StringName): return content_dict[content_id]

	for group_name in NetworkData.group_names:
		var script = PlayerScriptDict.data[group_name] as GDScript
		if script == null:
			continue

		var contents = network[group_name] as Array

		for content in contents:
			var player_content = script.new(content, data_of)
			_player_content_dict[content.id] = player_content

	_player_content_dict.make_read_only()


func player_data_of(content_id: StringName):
	return _player_content_dict[content_id]
