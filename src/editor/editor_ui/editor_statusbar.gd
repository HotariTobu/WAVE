extends HBoxContainer

var _editor_global = editor_global

func _ready():
	_editor_global.data.bind(&'tool').using(_get_tool_hint).to_label($ToolHintLabel)

static func _get_tool_hint(tool: EditorTool):
	return tool.get_status_hint()
