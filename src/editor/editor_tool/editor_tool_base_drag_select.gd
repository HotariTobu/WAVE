extends "res://src/editor/editor_tool/editor_tool_base_select.gd"

var _dragging: bool
var _shift: bool

var _selecting_item_set = Set.new()

var _last_mouse_pos: Vector2
var _current_mouse_pos: Vector2:
	get:
		return get_local_mouse_position()


func _unhandled_input(event):
	super(event)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_shift = event.shift_pressed
				_start_drag()
			else:
				_end_drag()


func _selecting(item: EditorSelectable):
	if _dragging:
		return

	super(item)


func _deselecting(item: EditorSelectable):
	if _dragging:
		return

	super(item)


func _replace_selection():
	if not _last_mouse_pos.is_equal_approx(_current_mouse_pos) or _selecting_item_set.size() >= 2:
		return

	super()


func _start_drag():
	if _dragging:
		return

	_dragging = true
	_last_mouse_pos = _current_mouse_pos

	if _last_hovered_item == null:
		return

	_selecting_item_set.add(_last_hovered_item)


func _end_drag():
	if not _dragging:
		return

	if _last_mouse_pos.is_equal_approx(_current_mouse_pos) and _selecting_item_set.size() < 2:
		_dispose()
		return

	if _shift:
		_remove_selection()
	else:
		_add_selection()

	_dispose()


func _add_selection():
	for item in _selecting_item_set.to_array():
		if item.selected:
			continue

		_editor_global.add_selected(item)


func _remove_selection():
	for item in _selecting_item_set.to_array():
		if not item.selected:
			continue

		_editor_global.remove_selected(item)


func _cancel():
	if _dragging:
		_dispose()
	else:
		super()


func _dispose():
	_dragging = false

	for item in _selecting_item_set.to_array():
		item.selecting = false

	_selecting_item_set.clear()
