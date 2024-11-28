extends "res://src/editor/editor_tool/editor_tool_base_select.gd"

var _dragging: bool
var _shift: bool

var _selecting_items: Array[EditorSelectable]


func _unhandled_input(event):
	super(event)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_shift = event.shift_pressed
				_start_drag()
			else:
				_end_drag()


func _on_pointer_area_area_entered(area):
	if _dragging:
		var item = area as EditorSelectable
		_hovered_items.append(item)

		item.selecting = true
		_selecting_items.append(item)

	else:
		super(area)


func _on_pointer_area_area_exited(area):
	if _dragging:
		var item = area as EditorSelectable
		_hovered_items.erase(item)

	else:
		super(area)


func _start_drag():
	if _dragging:
		return

	_dragging = true

	var item = _last_hovered_item
	if item == null:
		return

	_last_hovered_item = null

	item.selecting = true
	_selecting_items.append(item)


func _end_drag():
	if not _dragging:
		return

	_dragging = false

	if len(_selecting_items) < 2:
		_dispose()
		return

	if _shift:
		_remove_selection()
	else:
		_add_selection()

	_dispose()


func _add_selection():
	for item in _selecting_items:
		if item.selected:
			continue

		_editor_global.data.add_selected.call(item)


func _remove_selection():
	for item in _selecting_items:
		if not item.selected:
			continue

		_editor_global.data.remove_selected.call(item)


func _cancel():
	_dispose()
	super()


func _dispose():
	for item in _selecting_items:
		item.selecting = false

	_selecting_items.clear()

	if _hovered_items.is_empty():
		return

	_last_hovered_item = _hovered_items.back()
