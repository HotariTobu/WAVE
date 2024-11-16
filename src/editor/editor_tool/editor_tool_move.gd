extends "res://src/editor/editor_tool/editor_tool_base_select.gd"

const TOOL_DISPLAY_NAME = "Move tool"
const TOOL_STATUS_HINT = "Left click: select, Shift + Left click: add/remove select, Right drag: move"

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
#
	elif event is InputEventMouseButton:
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
	_tree.call_group(Group.SELECTION, &"reparent", _preview_container, false)


func _end_move():
	if _base_pos == Vector2.INF:
		return

	var items = _tree.get_nodes_in_group(Group.SELECTION)
	var movable_node_set = _get_movable_node_set(items)
	if movable_node_set.is_empty():
		return

	var offset = _current_pos - _base_pos

	_editor_global.undo_redo.create_action("Move")

	for movable_node in movable_node_set.to_array():
		_editor_global.undo_redo.add_do_method(movable_node.move_by.bind(offset))
		_editor_global.undo_redo.add_undo_method(movable_node.move_by.bind(-offset))

	_editor_global.undo_redo.commit_action()

	_dispose()


func _cancel():
	_dispose()
	super()


func _dispose():
	_base_pos = Vector2.INF
	_tree.call_group(Group.SELECTION, &"reparent", _content_container, false)


static func _get_movable_node_set(items: Array):
	var movable_node_set = Set.new()

	for item in items:
		if &"move_by" in item:
			movable_node_set.add(item)
		elif &"get_movable_nodes" in item:
			movable_node_set.add_all(item.get_movable_nodes())

	return movable_node_set
