extends "res://src/editor/editor_tool/editor_tool_base_drag_select.gd"

const TOOL_DISPLAY_NAME = "Rect select tool"
const TOOL_STATUS_HINT = "Left click: select, Shift + Left click: toggle selection, Left drag: add selection, Shift + Left drag: remove selection"

var _rect_area = RectArea.new()


func _init():
	super()

	_rect_area.collision_mask = _get_mask()
	_rect_area.area_entered.connect(_on_selection_area_area_entered)
	add_child(_rect_area)


func _unhandled_input(event):
	super(event)

	if event is InputEventMouseMotion:
		_update_selection_area()


func get_display_name() -> String:
	return TOOL_DISPLAY_NAME


func get_status_hint() -> String:
	return TOOL_STATUS_HINT


func _on_selection_area_area_entered(area):
	if not _dragging:
		return

	var item = area as EditorSelectable

	item.selecting = true
	_selecting_items.append(item)


func _update_selection_area():
	if not _dragging:
		return

	var last_mouse_pos = _last_mouse_pos
	var mouse_pos = _current_mouse_pos

	_rect_area.rect = Rect2(last_mouse_pos, mouse_pos - last_mouse_pos)


func _dispose():
	super()
	_rect_area.rect = Rect2()


class RectArea:
	extends Area2D

	var rect: Rect2:
		get:
			return rect
		set(value):
			var abs_rect = value.abs()

			rect = abs_rect

			position = (abs_rect.position + abs_rect.end) / 2
			_rect_shape.size = abs_rect.size

			queue_redraw()

	var _rect_shape = RectangleShape2D.new()

	func _init():
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = _rect_shape

		collision_layer = 0
		monitorable = false
		add_child(collision_shape)

	func _draw():
		draw_rect(Rect2(-rect.size / 2, rect.size), setting.selecting_color, false)
