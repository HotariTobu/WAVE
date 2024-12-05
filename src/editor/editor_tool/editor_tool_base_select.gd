extends "res://src/editor/editor_tool/editor_tool_base_pointer.gd"

var _last_hovered_item: EditorSelectable:
	get:
		return _last_hovered_item
	set(next):
		var prev = _last_hovered_item

		if prev != null:
			_deselecting(prev)

		if next != null:
			_selecting(next)

		_last_hovered_item = next


func _unhandled_input(event: InputEvent):
	super(event)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if event.shift_pressed:
				_toggle_selection()
			else:
				_replace_selection()

	elif event.is_action_pressed(&"ui_cancel"):
		_cancel()


func deactivate() -> void:
	super()
	_last_hovered_item = null


func _get_mask() -> int:
	return EditorPhysicsLayer.SELECTABLE


func _on_pointer_area_area_entered(area):
	super(area)
	_last_hovered_item = area


func _on_pointer_area_area_exited(area):
	super(area)
	if _hovered_items.is_empty():
		_last_hovered_item = null
	else:
		_last_hovered_item = _hovered_items.back()


func _selecting(item: EditorSelectable):
	item.selecting = true


func _deselecting(item: EditorSelectable):
	item.selecting = false


func _replace_selection():
	_editor_global.clear_selected()
	_toggle_selection()


func _toggle_selection():
	if _hovered_items.is_empty():
		return

	var item = _hovered_items.back()
	if item.selected:
		_editor_global.remove_selected(item)
	else:
		_editor_global.add_selected(item)


func _cancel():
	_editor_global.clear_selected()
