extends "res://src/editor/editor_tool/editor_tool_base_drag_select.gd"

const TOOL_DISPLAY_NAME = "Lasso select tool"
const TOOL_STATUS_HINT = "Left click: select, Shift + Left click: toggle selection, Left drag: add selection, Shift + Left drag: remove selection"

var _concave_area = ConcaveArea.new()


func _init():
	super()

	_concave_area.collision_mask = _get_mask()
	_concave_area.area_entered.connect(_on_selection_area_area_entered)
	_concave_area.area_exited.connect(_on_selection_area_area_exited)
	add_child(_concave_area)


func _unhandled_input(event):
	super(event)

	if event is InputEventMouseMotion:
		_update_selection_area()


func get_display_name() -> String:
	return TOOL_DISPLAY_NAME


func get_status_hint() -> String:
	return TOOL_STATUS_HINT


func activate() -> void:
	super()
	_concave_area.monitoring = true


func deactivate() -> void:
	super()
	_concave_area.monitoring = false


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

	_concave_area.add_point(_current_mouse_pos)


func _dispose():
	super()
	_concave_area.clear_points()


class ConcaveArea:
	extends Area2D

	var _concave_shape = ConcavePolygonShape2D.new()
	var _last_point = Vector2.INF

	func _init():
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = _concave_shape

		collision_layer = 0
		monitorable = false
		add_child(collision_shape)

	func _draw():
		var segments = _concave_shape.segments
		var len_segments = len(segments)
		if len_segments < 4:
			return

		@warning_ignore("integer_division")
		var point_count = len_segments / 2

		var points: PackedVector2Array
		points.resize(point_count)

		for index in range(point_count):
			points[index] = segments[index * 2]

		points.append(segments[-1])

		draw_polyline(points, setting.selecting_color)

	func add_point(point: Vector2):
		if _last_point == Vector2.INF:
			_last_point = point
			return

		_add_segment(_last_point, point)
		_last_point = point
		queue_redraw()

	func clear_points():
		_concave_shape.segments = []
		_last_point = Vector2.INF
		queue_redraw()

	func _add_segment(start: Vector2, end: Vector2):
		var segments = _concave_shape.segments
		var len_segments = len(segments)

		if len_segments < 2:
			segments.append(start)
			segments.append(end)
			segments.append(end)
			segments.append(start)
		else:
			segments.insert(len_segments - 1, end)
			segments.insert(len_segments - 1, end)

		_concave_shape.segments = segments
