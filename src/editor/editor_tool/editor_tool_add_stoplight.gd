extends EditorTool

const Dialog = preload('res://src/editor/editor_stoplight/editor_stoplight_dialog.tscn')

const TOOL_DISPLAY_NAME = 'Add Stoplight tool'
const TOOL_STATUS_HINT = 'Left click: add a stoplight'

var _editor_global = editor_global

@onready var _dialog = Dialog.instantiate()

func _ready():
	set_process_unhandled_input(false)

	add_child(_dialog)
	_dialog.canceled.connect(_on_canceled)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_add_new_stoplight()

func get_display_name() -> String:
	return TOOL_DISPLAY_NAME

func get_status_hint() -> String:
	return TOOL_STATUS_HINT

func activate() -> void:
	set_process_unhandled_input(true)

func deactivate() -> void:
	set_process_unhandled_input(false)

func _add_new_stoplight():
	var split_ids: Array[StringName]
	var new_splits: Array[SplitData]
	
	for _index in range(setting.default_split_count):
		var split = SplitData.new()
		split.duration = setting.default_split_duration
		split_ids.append(split.id)
		new_splits.append(split)
		
	var stoplight = EditorStoplightData.new()
	stoplight.pos = get_local_mouse_position()
	stoplight.offset = setting.default_stoplight_offset
	stoplight.split_ids = split_ids

	_editor_global.undo_redo.create_action("Add stoplight")
	
	for split in new_splits:
		_editor_global.undo_redo.add_do_method(_editor_global.split_db.add.bind(split))
		_editor_global.undo_redo.add_do_reference(split)
		_editor_global.undo_redo.add_undo_method(_editor_global.split_db.remove.bind(split))
	
	_editor_global.undo_redo.add_do_method(_editor_global.stoplight_db.add.bind(stoplight))
	_editor_global.undo_redo.add_do_reference(stoplight)
	_editor_global.undo_redo.add_undo_method(_editor_global.stoplight_db.remove.bind(stoplight))
	
	_editor_global.undo_redo.commit_action()

	_dialog.stoplight = stoplight
	_dialog.show()

func _on_canceled():
	var stoplight = _dialog.stoplight as EditorStoplightData
	var splits = stoplight.split_ids.map(_editor_global.split_db.get_of)

	_editor_global.undo_redo.create_action("Remove stoplight")
	
	for split in splits:
		_editor_global.undo_redo.add_do_method(_editor_global.split_db.remove.bind(split))
		_editor_global.undo_redo.add_undo_method(_editor_global.split_db.add.bind(split))
		_editor_global.undo_redo.add_undo_reference(split)
	
	_editor_global.undo_redo.add_do_method(_editor_global.stoplight_db.remove.bind(stoplight))
	_editor_global.undo_redo.add_undo_method(_editor_global.stoplight_db.add.bind(stoplight))
	_editor_global.undo_redo.add_undo_reference(stoplight)
	
	_editor_global.undo_redo.commit_action()
