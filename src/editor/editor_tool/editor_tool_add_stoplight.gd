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
	var pos = get_local_mouse_position()

	var stoplight = EditorStoplight.new()
	stoplight.position = pos

	_editor_global.undo_redo.create_action("Add stoplight")
	_editor_global.undo_redo.add_do_method(_editor_global.content_container.add_child.bind(stoplight))
	_editor_global.undo_redo.add_do_reference(stoplight)
	_editor_global.undo_redo.add_undo_method(_editor_global.content_container.remove_child.bind(stoplight))
	_editor_global.undo_redo.commit_action()

	_dialog.stoplight = stoplight
	_dialog.show()

func _on_canceled():
	var stoplight = _dialog.stoplight

	_editor_global.undo_redo.create_action("Remove stoplight")
	_editor_global.undo_redo.add_do_method(_editor_global.content_container.remove_child.bind(stoplight))
	_editor_global.undo_redo.add_undo_method(_editor_global.content_container.add_child.bind(stoplight))
	_editor_global.undo_redo.add_undo_reference(stoplight)
	_editor_global.undo_redo.commit_action()
