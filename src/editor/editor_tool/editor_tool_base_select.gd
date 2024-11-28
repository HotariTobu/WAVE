extends EditorTool

var _editor_global = editor_global

var _hovered_items: Array[EditorSelectable]
var _last_hovered_item: EditorSelectable:
	get:
		return _last_hovered_item
	set(next):
		var prev = _last_hovered_item

		if prev != null:
			prev.selecting = false
			_on_deselecting(prev)

		if next != null:
			next.selecting = true
			_on_selecting(next)

		_last_hovered_item = next


func _ready():
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		_pointer_area.position = get_local_mouse_position()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if event.shift_pressed:
				_toggle_selection()
			else:
				_replace_selection()

	elif event.is_action_pressed(&"ui_cancel"):
		_cancel()


func activate() -> void:
	set_process_unhandled_input(true)

	_pointer_area.collision_mask = _get_mask()

	_pointer_area.area_entered.connect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.connect(_on_pointer_area_area_exited)


func deactivate() -> void:
	set_process_unhandled_input(false)

	_pointer_area.collision_mask = 0

	_pointer_area.area_entered.disconnect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.disconnect(_on_pointer_area_area_exited)

	_hovered_items.clear()
	_last_hovered_item = null


func _get_mask() -> int:
	return EditorPhysicsLayer.SELECTABLE


func _on_pointer_area_area_entered(area):
	var item = area as EditorSelectable
	_hovered_items.append(item)
	_last_hovered_item = item


func _on_pointer_area_area_exited(area):
	var item = area as EditorSelectable
	_hovered_items.erase(item)
	if _hovered_items.is_empty():
		_last_hovered_item = null
	else:
		_last_hovered_item = _hovered_items.back()


func _on_selecting(_item: EditorSelectable):
	pass


func _on_deselecting(_item: EditorSelectable):
	pass


func _replace_selection():
	_editor_global.data.clear_selected.call()
	_toggle_selection()


func _toggle_selection():
	if _hovered_items.is_empty():
		return

	var item = _hovered_items.back()
	if item.selected:
		_editor_global.data.remove_selected.call(item)
	else:
		_editor_global.data.add_selected.call(item)


func _cancel():
	_editor_global.data.clear_selected.call()
