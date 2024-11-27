extends Node

var _editor_global = editor_global


func copy_selection():
	var sub_network_dict: Dictionary

	var copy_source_ids: Array[StringName]
	var copy_dependency_id_set = Set.new()

	for content in _editor_global.data.selected_contents:
		copy_source_ids.append(content.id)
		copy_dependency_id_set.add(content.id)

		var constraint = _editor_global.constraint_db.of(content.id)
		copy_dependency_id_set.merge(constraint.copy_dependency_id_set)

	for content_id in copy_dependency_id_set.to_array():
		var group = _editor_global.content_db.group_of(content_id)
		var content_dicts = sub_network_dict.get_or_add(group.name, []) as Array
		var content = group.data_of(content_id)
		var script = content.get_script() as GDScript
		var content_dict = script.to_dict(content)
		content_dicts.append(content_dict)

	sub_network_dict[&"copy_source_ids"] = copy_source_ids

	var json = JSON.stringify(sub_network_dict)
	DisplayServer.clipboard_set(json)
