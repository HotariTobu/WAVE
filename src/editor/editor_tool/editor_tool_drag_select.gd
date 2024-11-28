extends "res://src/editor/editor_tool/editor_tool_base_drag_select.gd"

const TOOL_DISPLAY_NAME = "Drag select tool"
const TOOL_STATUS_HINT = "Left click: select, Shift + Left click: toggle selection, Left drag: add selection, Shift + Left drag: remove selection"


func get_display_name() -> String:
	return TOOL_DISPLAY_NAME


func get_status_hint() -> String:
	return TOOL_STATUS_HINT
