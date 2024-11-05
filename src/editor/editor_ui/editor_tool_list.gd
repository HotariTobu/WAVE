extends VBoxContainer

signal selected_tool_changed(next_tool: EditorTool)

@export var shortcut_manager: ShortcutManager

var tools: Array[EditorTool]:
	get:
		return tools
	set(value):
		tools = value
		_update_tool_buttons()
		
var selected_tool: EditorTool:
	get:
		return selected_tool
	set(value):
		selected_tool = value
		_toggle_tool_buttons()
		

var _editor_global = editor_global

func _ready():
	_editor_global.data.bind('tools').to(self, 'tools')
	_editor_global.data.bind('tool').to(self, 'selected_tool', selected_tool_changed)

	shortcut_manager.handled.connect(_on_tool_shortcut_manager_handled)

func _update_tool_buttons():
	for child in get_children():
		child.queue_free()

	shortcut_manager.clear_shortcuts()

	for tool in tools:
		var button = ToolButton.new(tool)
		button.selected.connect(_on_tool_button_selected.bind(tool))
		add_child(button)

		shortcut_manager.add_shortcut(tool.shortcut, tool)

func _toggle_tool_buttons():
	var tool_id = selected_tool.get_id()
	for child in get_children():
		var button = child as ToolButton
		if button.tool_id == tool_id:
			button.button_pressed = true
			break

func _on_tool_shortcut_manager_handled(targets: Array[Variant]):
	var focused_control = get_viewport().gui_get_focus_owner()
	if focused_control is LineEdit or focused_control is TextEdit:
		return

	var prev_tool = selected_tool
	var index = targets.find(prev_tool) + 1
	var next_tool = targets[index % len(targets)]
	_update_selected_tool(next_tool)

func _on_tool_button_selected(next_tool: EditorTool):
	_update_selected_tool(next_tool)

func _update_selected_tool(next_tool: EditorTool):
	selected_tool = next_tool
	selected_tool_changed.emit(selected_tool)

class ToolButton extends Button:
	signal selected

	var tool_id: StringName

	func _init(tool: EditorTool):
		tool_id = tool.get_id()
		text = tool.get_display_name()
		button_group = tool_button_group
		toggle_mode = true
		toggled.connect(_on_toggled)

	func _on_toggled(toggled_on: bool):
		if not toggled_on:
			return

		selected.emit()

	static var tool_button_group = ButtonGroup.new()
