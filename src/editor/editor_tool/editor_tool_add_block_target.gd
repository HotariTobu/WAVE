extends "res://src/editor/editor_tool/editor_tool_base_select.gd"

const TOOL_DISPLAY_NAME = "Add Block Target tool"
const TOOL_STATUS_HINT = "Left click: select a source, Shift + Left click: toggle a source, Right click: toggle a target, Ctrl/Cmd: show targets"

var _source_sources: Array[EditorBindingSource]:
	get:
		return _source_sources
	set(next):
		var prev = _source_sources
		_unbind_source_sources(prev)
		_bind_source_sources(next)
		_source_sources = next
		_update_target_id_set()

var _target_id_set = Set.new():
	get:
		return _target_id_set
	set(next):
		var prev = _target_id_set

		for target_node in _get_block_targetables(prev.to_array()):
			target_node.block_targeted = false

		for target_node in _get_block_targetables(next.to_array()):
			target_node.block_targeted = true

		_target_id_set = next

var _are_targets_visible: bool = false:
	get:
		return _are_targets_visible
	set(value):
		_are_targets_visible = value

		if _last_hovered_item == null:
			return

		_update_targets_visibility(_last_hovered_item, value)


func _unhandled_input(event: InputEvent):
	super(event)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if event.alt_pressed:
				_toggle_target()

		if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			_toggle_target()

	elif event is InputEventKey:
		if event.keycode == KEY_CTRL or event.keycode == KEY_META:
			_are_targets_visible = event.pressed


func get_display_name() -> String:
	return TOOL_DISPLAY_NAME


func get_status_hint() -> String:
	return TOOL_STATUS_HINT


func activate() -> void:
	super()

	var converter = ContentsToFilteredSourcesConverter.new(_is_block_source)
	_editor_global.source.bind(&"selected_contents").using(converter).to(self, &"_source_sources")


func deactivate() -> void:
	super()

	_editor_global.source.unbind(&"selected_contents").from(self, &"_source_sources")
	_source_sources = []


func _get_mask() -> int:
	return EditorPhysicsLayer.BRIDGE_SEGMENTS | EditorPhysicsLayer.LANE_SEGMENTS | EditorPhysicsLayer.STOPLIGHT


func _selecting(item: EditorSelectable):
	super(item)
	_update_targets_visibility(item, _are_targets_visible)


func _deselecting(item: EditorSelectable):
	super(item)
	_update_targets_visibility(item, false)


func _replace_selection():
	if Input.is_key_pressed(KEY_ALT):
		return

	super()


func _bind_source_sources(source_sources: Array[EditorBindingSource]):
	for source_source in source_sources:
		source_source.add_callback(&"block_target_ids", _update_target_id_set)


func _unbind_source_sources(source_sources: Array[EditorBindingSource]):
	for source_source in source_sources:
		source_source.remove_callback(&"block_target_ids", _update_target_id_set)


func _update_target_id_set():
	var block_target_id_sets: Array[Set]

	for source_source in _source_sources:
		var block_target_id_set = Set.from_array(source_source.block_target_ids)
		block_target_id_sets.append(block_target_id_set)

	if block_target_id_sets.is_empty():
		_target_id_set = Set.new()
		return

	var target_id_set = block_target_id_sets.pop_back() as Set

	for block_target_id_set in block_target_id_sets:
		target_id_set.intersect(block_target_id_set)

	_target_id_set = target_id_set


func _update_targets_visibility(source_node: EditorSelectable, are_targets_visible: bool):
	var source = source_node.data
	if not _is_block_source(source):
		return

	for target_node in _get_block_targetables(source.block_target_ids):
		target_node.block_targeting = are_targets_visible


func _get_block_targetables(block_target_ids: Array) -> Array[EditorBlockTargetable]:
	var block_targetables = block_target_ids.map(_editor_global.content_node_of)
	return Array(block_targetables, TYPE_OBJECT, &"Area2D", EditorBlockTargetable)


func _toggle_target():
	var item = _last_hovered_item
	if item == null:
		return

	if item is not EditorBlockTargetable:
		return

	var content = item.data
	if _target_id_set.has(content.id):
		_remove_block_target(content)
	else:
		_add_block_target(content)


func _add_block_target(target: ContentData):
	_editor_global.undo_redo.create_action("Add block target")

	for source_source in _source_sources:
		var prev = source_source.block_target_ids as Array
		var next = prev.duplicate()
		next.append(target.id)

		_editor_global.undo_redo.add_do_property(source_source, &"block_target_ids", next)
		_editor_global.undo_redo.add_undo_property(source_source, &"block_target_ids", prev)

	_editor_global.undo_redo.commit_action()


func _remove_block_target(target: ContentData):
	_editor_global.undo_redo.create_action("Remove block target")

	for source_source in _source_sources:
		var prev = source_source.block_target_ids as Array
		var next = prev.duplicate()
		next.erase(target.id)

		_editor_global.undo_redo.add_do_property(source_source, &"block_target_ids", next)
		_editor_global.undo_redo.add_undo_property(source_source, &"block_target_ids", prev)

	_editor_global.undo_redo.commit_action()


static func _is_block_source(content: ContentData) -> bool:
	return &"block_target_ids" in content
