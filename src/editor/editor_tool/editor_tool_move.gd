extends "res://src/editor/editor_tool/editor_tool_base_select.gd"

const TOOL_DISPLAY_NAME = "Move tool"
const TOOL_STATUS_HINT = "Left click: select, Shift + Left click: toggle selection, Right drag: move"

@export var _content_container: Node

var _preview_container = Node2D.new()

var _base_pos = Vector2.INF

var _current_pos: Vector2:
	get:
		return get_local_mouse_position()

@onready var _tree = get_tree()


func _init():
	super()
	add_child(_preview_container)


func _unhandled_input(event: InputEvent):
	super(event)

	if event is InputEventMouseMotion:
		_move_preview()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if event.alt_pressed:
					_start_move()
			else:
				_end_move()

		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_start_move()
			else:
				_end_move()


func get_display_name() -> String:
	return TOOL_DISPLAY_NAME


func get_status_hint() -> String:
	return TOOL_STATUS_HINT


func _get_mask() -> int:
	return EditorPhysicsLayer.BRIDGE | EditorPhysicsLayer.LANE | EditorPhysicsLayer.STOPLIGHT_CORE

func _replace_selection():
	if _base_pos != Vector2.INF:
		return

	super()

func _move_preview():
	if _base_pos == Vector2.INF:
		return

	var offset = _current_pos - _base_pos
	_preview_container.position = offset


func _start_move():
	if _base_pos != Vector2.INF:
		return

	_preview_container.position = Vector2.ZERO

	_base_pos = _current_pos
	_tree.call_group(NodeGroup.SELECTION, &"reparent", _preview_container, false)


func _end_move():
	if _base_pos == Vector2.INF:
		return

	var movable_id_set = Set.new()

	for content in _editor_global.data.selected_contents:
		var constraint = _editor_global.constraint_db.of(content.id)
		constraint.merge_movable_id_set_to(movable_id_set)

	if movable_id_set.is_empty():
		_dispose()
		return

	var offset = _current_pos - _base_pos

	_editor_global.undo_redo.create_action("Move")

	for content_id in movable_id_set.to_array():
		var group_name = _editor_global.content_db.group_name_of(content_id)
		var helper_script = EditorScriptDict.helper[group_name]
		var content = _editor_global.content_db.data_of(content_id)
		var source = _editor_global.source_db.get_or_add(content)
		_editor_global.undo_redo.add_do_method(helper_script.move_by.bind(source, offset))
		_editor_global.undo_redo.add_undo_method(helper_script.move_by.bind(source, -offset))

	_editor_global.undo_redo.commit_action()

	_dispose()


func _cancel():
	_dispose()
	super()


func _dispose():
	_base_pos = Vector2.INF
	_tree.call_group(NodeGroup.SELECTION, &"reparent", _content_container, false)
