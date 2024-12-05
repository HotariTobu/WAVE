extends "res://src/editor/editor_tool/editor_tool_base_drag_select.gd"

const TOOL_DISPLAY_NAME = "Drag select tool"
const TOOL_STATUS_HINT = "Left click: select, Shift + Left click: toggle selection, Left drag: add selection, Shift + Left drag: remove selection"

var _segments_area = SegmentsArea.new()


func _init():
	super()

	_segments_area.collision_mask = _get_mask()
	_segments_area.area_entered.connect(_on_selection_area_area_entered)
	_segments_area.area_exited.connect(_on_selection_area_area_exited)
	add_child(_segments_area)


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
	_selecting_item_set.add(item)


func _on_selection_area_area_exited(area):
	if not _dragging:
		return

	var item = area as EditorSelectable

	item.selecting = false
	_selecting_item_set.erase(item)


func _update_selection_area():
	if not _dragging:
		return

	_segments_area.add_point(_current_mouse_pos)


func _dispose():
	super()
	_segments_area.clear_points()


class SegmentsArea:
	extends Area2D

	var _collision_shapes = ObservableArray.new()
	var _last_point = Vector2.INF

	func _init():
		collision_layer = 0
		monitorable = false
		input_pickable = false

		_collision_shapes.value_inserted.connect(add_child.unbind(1))
		_collision_shapes.value_removed.connect(remove_child.unbind(1))

	func add_point(point: Vector2):
		if _last_point == Vector2.INF:
			_last_point = point
			return

		_add_segment(_last_point, point)
		_last_point = point

	func clear_points():
		_collision_shapes.clear()
		_last_point = Vector2.INF

	func _add_segment(start: Vector2, end: Vector2):
		var segment_shape = SegmentShape2D.new()
		segment_shape.a = start
		segment_shape.b = end

		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = segment_shape
		_collision_shapes.append(collision_shape)
