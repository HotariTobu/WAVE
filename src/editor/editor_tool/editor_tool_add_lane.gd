extends EditorTool

const TOOL_DISPLAY_NAME = 'Add Lane tool'
const TOOL_STATUS_HINT = 'Left click: add a point, Right click: commit the lane'

enum Phase {EMPTY, LACK, ENOUGH}

var _editor_global = editor_global

var _preview_lane: EditorLane = null
var _prev_lane: EditorLane = null
var _next_lane: EditorLane = null

var _phase: Phase:
	get:
		if _preview_lane.curve.point_count < 2:
			return Phase.EMPTY
		elif _preview_lane.curve.point_count < 3:
			return Phase.LACK
		else:
			return Phase.ENOUGH

var _selecting_point: EditorLanePoint = null:
	get:
		return _selecting_point
	set(value):
		if _selecting_point != null:
			_selecting_point.selecting = false

		if value != null:
			value.selecting = true

		_selecting_point = value

var _point_pos:
	get:
		if _selecting_point == null:
			return get_local_mouse_position()
		else:
			return _selecting_point.position

func _ready():
	set_process_unhandled_input(false)

	_preview_lane = EditorLane.new(false)
	_preview_lane.curve = Curve2D.new()
	add_child(_preview_lane)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		_update_end_point()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_add_new_point()

		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			_commit_lane()

	elif event.is_action_pressed("ui_cancel"):
		_cancel()

func get_display_name() -> String:
	return TOOL_DISPLAY_NAME

func get_status_hint() -> String:
	return TOOL_STATUS_HINT

func activate() -> void:
	set_process_unhandled_input(true)

	_editor_global.pointer_area.collision_mask = EditorPhysicsLayer.LANE_POINT

	_editor_global.pointer_area.area_entered.connect(_on_pointer_area_area_entered)
	_editor_global.pointer_area.area_exited.connect(_on_pointer_area_area_exited)

func deactivate() -> void:
	set_process_unhandled_input(false)

	_editor_global.pointer_area.collision_mask = 0

	_editor_global.pointer_area.area_entered.disconnect(_on_pointer_area_area_entered)
	_editor_global.pointer_area.area_exited.disconnect(_on_pointer_area_area_exited)

	_cancel()
	_selecting_point = null


func _on_pointer_area_area_entered(area):
	var point = area as EditorLanePoint
	match point.type:
		EditorLanePoint.Type.START:
			if _phase != Phase.EMPTY:
				_selecting_point = point
				_update_end_point()

		EditorLanePoint.Type.END:
			if _phase == Phase.EMPTY:
				_selecting_point = point

func _on_pointer_area_area_exited(area):
	if _selecting_point == area:
		_selecting_point = null


func _update_end_point():
	if _phase == Phase.EMPTY:
		return

	_preview_lane.curve.set_point_position(_preview_lane.curve.point_count - 1, _point_pos)
	_preview_lane.queue_redraw()

func _add_new_point():
	var empty = _phase == Phase.EMPTY
	if empty:
		_preview_lane.curve.add_point(_point_pos)

	_preview_lane.curve.add_point(_point_pos)

	if _selecting_point == null:
		return

	if empty:
		_prev_lane = _selecting_point.lane
		_selecting_point = null
	else:
		_next_lane = _selecting_point.lane
		_commit_lane()

func _commit_lane():
	if _phase != Phase.ENOUGH:
		_cancel()
		return

	_preview_lane.curve.remove_point(_preview_lane.curve.point_count - 1)

	var lane = EditorLane.new()
	lane.curve = _preview_lane.curve

	if _next_lane != null:
		lane.add_next_lane(_next_lane)

	_editor_global.undo_redo.create_action("Add lane")
	_editor_global.undo_redo.add_do_method(_editor_global.content_container.add_child.bind(lane))
	_editor_global.undo_redo.add_do_reference(lane)
	_editor_global.undo_redo.add_undo_method(_editor_global.content_container.remove_child.bind(lane))
	if _prev_lane != null:
		_editor_global.undo_redo.add_do_method(_prev_lane.add_next_lane.bind(lane))
		_editor_global.undo_redo.add_undo_method(_prev_lane.remove_next_lane.bind(lane))
	_editor_global.undo_redo.commit_action()

	_cancel()
	_selecting_point = null

func _cancel():
	_preview_lane.curve = Curve2D.new()
	_preview_lane.queue_redraw()

	_prev_lane = null
	_next_lane = null

	if _selecting_point == null:
		return

	if _selecting_point.type == EditorLanePoint.Type.END:
		return

	_selecting_point = null
