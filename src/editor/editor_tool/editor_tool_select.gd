extends EditorTool

const TOOL_DISPLAY_NAME = 'Select tool'
const TOOL_STATUS_HINT = 'Left click: select, Shift + Left click: add/remove select'

var _editor_global = editor_global

var _hovered_items: Array[EditorSelectable] = []

func _ready():
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if event.shift_pressed:
				_toggle_selection()
			else:
				_replace_selection()

	elif event.is_action_pressed("ui_cancel"):
		_cancel()

func get_display_name() -> String:
	return TOOL_DISPLAY_NAME

func get_status_hint() -> String:
	return TOOL_STATUS_HINT

func activate() -> void:
	set_process_unhandled_input(true)

	_pointer_area.collision_mask = EditorPhysicsLayer.SELECTABLE

	_pointer_area.area_entered.connect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.connect(_on_pointer_area_area_exited)

func deactivate() -> void:
	set_process_unhandled_input(false)

	_pointer_area.collision_mask = 0

	_pointer_area.area_entered.disconnect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.disconnect(_on_pointer_area_area_exited)

	_cancel()

	if not _hovered_items.is_empty():
		var last_item = _hovered_items.back()
		last_item.selecting = false

		_hovered_items.clear()


func _on_pointer_area_area_entered(area):
	if not _hovered_items.is_empty():
		var last_item = _hovered_items.back()
		last_item.selecting = false

	var item = area as EditorSelectable
	item.selecting = true
	_hovered_items.append(item)

func _on_pointer_area_area_exited(area):
	var item = area as EditorSelectable
	item.selecting = false
	_hovered_items.erase(item)

	if not _hovered_items.is_empty():
		var last_item = _hovered_items.back()
		last_item.selecting = true


func _replace_selection():
	_cancel()
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
