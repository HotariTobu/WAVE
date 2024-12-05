extends Node

const PASTE_OFFSET = 10

var _editor_global = editor_global

var _last_paste_anchor_pos: Vector2
var _last_paste_offset: float


func copy_selection():
	var sub_network_dict: Dictionary

	var selected_ids: Array[StringName]
	var copy_dependency_id_set = Set.new()

	for content in _editor_global.selected_contents:
		selected_ids.append(content.id)
		copy_dependency_id_set.add(content.id)

		var constraint = _editor_global.constraint_db.of(content.id)
		constraint.merge_copy_dependency_id_set_to(copy_dependency_id_set)

	for content_id in copy_dependency_id_set.to_array():
		var group = _editor_global.content_db.group_of(content_id)
		var content_dicts = sub_network_dict.get_or_add(group.name, []) as Array
		var content = group.data_of(content_id)
		var script = content.get_script() as GDScript
		var content_dict = script.to_dict(content)
		content_dicts.append(content_dict)

	sub_network_dict[&"selected_ids"] = selected_ids
	sub_network_dict[&"anchor_pos"] = VertexData.Pos.to_dict(_get_anchor_pos())

	var json = JSON.stringify(sub_network_dict)
	DisplayServer.clipboard_set(json)


func paste(selected_only: bool):
	if not DisplayServer.clipboard_has():
		return

	var json = DisplayServer.clipboard_get()
	var sub_network_dict = JSON.parse_string(json)
	if sub_network_dict == null or sub_network_dict is not Dictionary:
		return

	var selected_ids = sub_network_dict.get(&"selected_ids")
	if selected_ids == null or selected_ids is not Array:
		return

	var anchor_pos_dict = sub_network_dict.get(&"anchor_pos")
	if anchor_pos_dict == null or anchor_pos_dict is not Dictionary:
		return

	var copy_anchor_pos = VertexData.Pos.form_dict(anchor_pos_dict)
	if not copy_anchor_pos.is_finite():
		return

	var clone_result = _clone(sub_network_dict, selected_only)

	_editor_global.undo_redo.create_action("Paste")

	for group_name in clone_result.group_name_contents_dict:
		var group = _editor_global.content_db.get_group(group_name)
		var contents = clone_result.group_name_contents_dict[group_name]

		for content in contents:
			_editor_global.undo_redo.add_do_method(group.add.bind(content))
			_editor_global.undo_redo.add_undo_method(group.remove.bind(content))

	_editor_global.undo_redo.add_do_method(_select_pasted_content_nodes.bind(clone_result.new_ids))

	_editor_global.undo_redo.commit_action()

	_move.call_deferred(clone_result.group_name_contents_dict, copy_anchor_pos)


func _clone(sub_network_dict: Dictionary, _selected_only: bool):
	var group_name_contents_dict: Dictionary
	var new_id_dict: Dictionary

	for group_name in NetworkData.group_names:
		var content_dicts = sub_network_dict.get(group_name)
		if content_dicts == null or content_dicts is not Array:
			continue

		var data_script = NetworkData.content_data_script_dict[group_name] as GDScript

		var contents: Array[ContentData]

		for content_dict in content_dicts:
			var old_id = content_dict[&"id"]
			content_dict.erase(&"id")

			var content = data_script.from_dict(content_dict)
			new_id_dict[old_id] = content.id

			contents.append(content)

		group_name_contents_dict[group_name] = contents

	# if selected_only:
	# 	var selected_id_set = Set.from_array(selected_ids)
	# 	var selected_only_new_id_dict: Dictionary

	# for old_id in new_id_dict:
	# 	if not selected_id_set.has(old_id):
	# 		continue

	# var new_id = new_id_dict[old_id]
	# selected_only_new_id_dict[old_id] = new_id

	# new_id_dict = selected_only_new_id_dict

	new_id_dict.make_read_only()

	var new_id_of = func(old_id: StringName): return new_id_dict.get(old_id)

	for group_name in group_name_contents_dict:
		var contents = group_name_contents_dict[group_name]
		var helper_script = EditorScriptDict.helper[group_name] as GDScript

		for content in contents:
			helper_script.replace_id(content, new_id_of)

	var result = CloneResult.new()
	result.group_name_contents_dict = group_name_contents_dict
	result.new_ids.assign(new_id_dict.values())

	return result


func _move(group_name_contents_dict: Dictionary, copy_anchor_pos: Vector2) -> void:
	var all_contents: Array[ContentData]

	for contents in group_name_contents_dict.values():
		all_contents.append_array(contents)

	var movable_id_set = Set.new()

	for content in all_contents:
		var constraint = _editor_global.constraint_db.of(content.id)
		constraint.merge_movable_id_set_to(movable_id_set)

	if movable_id_set.is_empty():
		return

	var paste_anchor_pos = _get_anchor_pos()
	if _last_paste_anchor_pos != paste_anchor_pos:
		_last_paste_anchor_pos = paste_anchor_pos
		_last_paste_offset = 0

	_last_paste_offset += _get_paste_offset()
	var paste_offset = paste_anchor_pos - copy_anchor_pos + Vector2.ONE * _last_paste_offset

	for content_id in movable_id_set.to_array():
		var group_name = _editor_global.content_db.group_name_of(content_id)
		var helper_script = EditorScriptDict.helper[group_name]
		var content = _editor_global.content_db.data_of(content_id)
		var source = _editor_global.source_db.get_or_add(content)
		helper_script.move_by(source, paste_offset)


func _get_anchor_pos():
	return _editor_global.camera.get_screen_center_position()


func _get_paste_offset():
	return PASTE_OFFSET / _editor_global.camera.zoom_value


func _select_pasted_content_nodes(content_ids: Array[StringName]):
	var content_nodes: Array[EditorContent]
	content_nodes.assign(content_ids.map(_editor_global.content_node_of))
	_editor_global.clear_selected()
	_editor_global.add_all_selected(content_nodes)


class CloneResult:
	var group_name_contents_dict: Dictionary
	var new_ids: Array[StringName]
