extends EditorTool

const TOOL_DISPLAY_NAME = 'Add Block Target tool'
const TOOL_STATUS_HINT = 'Left click: select a source, Right click: select a target, Shift: show sources, Ctrl/Cmd: show targets'

var _editor_global = editor_global

var _hovered_items: Array[EditorSelectable] = []
var _last_hovered_item: EditorSelectable = null:
	get:
		return _last_hovered_item
	set(next):
		var prev = _last_hovered_item

		if prev != null:
			prev.selecting = false
			_update_source_visibility(prev, false)
			_update_target_visibility(prev, false)

		if next != null:
			next.selecting = true
			_update_source_visibility(next, _is_sources_visible)
			_update_target_visibility(next, _is_targets_visible)

		_last_hovered_item = next

var _selected_source_item: EditorSelectable = null:
	get:
		return _selected_source_item
	set(next):
		var prev = _selected_source_item

		if prev != null:
			prev.selected = false

		if next != null:
			next.selected = true

		_selected_source_item = next

var _selected_target_item: EditorSelectable = null:
	get:
		return _selected_target_item
	set(next):
		var prev = _selected_target_item

		if prev != null:
			prev.selected = false

		if next != null:
			next.selected = true

		_selected_target_item = next

var _selected_stoplight: EditorStoplight = null:
	get:
		return _selected_stoplight
	set(next):
		var prev = _selected_stoplight

		if prev != null:
			prev.opened = false

		if next != null:
			next.opened = true

		_selected_stoplight = next

var _is_sources_visible: bool = false:
	get:
		return _is_sources_visible
	set(value):
		_is_sources_visible = value

		var item = _last_hovered_item
		if item == null:
			return

		_update_source_visibility(item, value)

var _is_targets_visible: bool = false:
	get:
		return _is_targets_visible
	set(value):
		_is_targets_visible = value

		var item = _last_hovered_item
		if item == null:
			return

		_update_target_visibility(item, value)

func _ready():
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		queue_redraw()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_select_source()

		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			_select_target()

	elif event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			_is_sources_visible = event.pressed

		elif event.keycode == KEY_CTRL or event.keycode == KEY_META:
			_is_targets_visible = event.pressed

		elif event.is_action_pressed(&"ui_cancel"):
			_cancel()

func _draw():
	var start_pos: Vector2

	if _selected_source_item != null:
		start_pos = _selected_source_item.to_global(_selected_source_item.get_center())
	elif _selected_target_item != null:
		start_pos = _selected_target_item.to_global(_selected_target_item.get_center())
	else:
		return

	var end_pos = get_local_mouse_position()
	var color = setting.block_line_color

	draw_dashed_line(start_pos, end_pos, color)

func get_display_name() -> String:
	return TOOL_DISPLAY_NAME

func get_status_hint() -> String:
	return TOOL_STATUS_HINT

func activate() -> void:
	set_process_unhandled_input(true)

	var mask = EditorPhysicsLayer.BRIDGE_SEGMENTS | EditorPhysicsLayer.LANE_SEGMENTS | EditorPhysicsLayer.STOPLIGHT
	_editor_global.pointer_area.collision_mask = mask

	_editor_global.pointer_area.area_entered.connect(_on_pointer_area_area_entered)
	_editor_global.pointer_area.area_exited.connect(_on_pointer_area_area_exited)

func deactivate() -> void:
	set_process_unhandled_input(false)

	_editor_global.pointer_area.collision_mask = 0

	_editor_global.pointer_area.area_entered.disconnect(_on_pointer_area_area_entered)
	_editor_global.pointer_area.area_exited.disconnect(_on_pointer_area_area_exited)

	_cancel()
	_hovered_items.clear()
	_last_hovered_item = null
	_is_sources_visible = false
	_is_targets_visible = false


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


func _select_source():
	var item = _last_hovered_item
	if item == null:
		return

	if item is EditorStoplightCore:
		_selected_stoplight = item.stoplight
		return

	_selected_source_item = item

	if _selected_target_item == null:
		return

	_add_block_target()


func _select_target():
	var item = _last_hovered_item
	if item == null:
		return

	if item is EditorStoplightCore or item is EditorStoplightSector:
		return

	_selected_target_item = item

	if _selected_source_item == null:
		return

	_add_block_target()

func _add_block_target():
	var source = _get_source(_selected_source_item)
	var target = _get_target(_selected_target_item)

	_editor_global.undo_redo.create_action("Add block target")
	_editor_global.undo_redo.add_do_method(func(): source.block_targets.append(target))
	_editor_global.undo_redo.add_do_method(func(): target.block_sources.append(source))
	_editor_global.undo_redo.add_undo_method(func(): source.block_targets.erase(target))
	_editor_global.undo_redo.add_undo_method(func(): target.block_sources.erase(source))
	_editor_global.undo_redo.commit_action()

	_selected_source_item = null
	_selected_target_item = null

func _cancel():
	_selected_source_item = null
	_selected_target_item = null
	_selected_stoplight = null

static func _update_source_visibility(item: EditorSelectable, is_sources_visible: bool):
	var target = _get_target(item)
	if target == null:
		return

	for block_source in target.block_sources:
		block_source.selecting = is_sources_visible

static func _update_target_visibility(item: EditorSelectable, is_targets_visible: bool):
	var source = _get_source(item)
	if source == null:
		return

	for block_target in source.block_targets:
		block_target.selecting = is_targets_visible

static func _get_source(item: EditorSelectable):
	if item is EditorStoplightSector:
		return item.split

	if item is EditorLaneSegments:
		return item.lane

	return null

static func _get_target(item: EditorSelectable):
	if item is EditorLaneSegments:
		return item.lane

	return null
