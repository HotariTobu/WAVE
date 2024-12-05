extends GutTest

const EditorStatusbarScene = preload("res://src/editor/editor_ui/editor_statusbar.tscn")

var _editor_global

var _tool1
var _tool2

var _statusbar


func before_each():
	_editor_global = autofree(EditorGlobal.new())

	_tool1 = autofree(double(EditorTool).new())
	_tool2 = autofree(double(EditorTool).new())

	_statusbar = EditorStatusbarScene.instantiate()
	_statusbar._editor_global = _editor_global
	add_child_autofree(_statusbar)


func test_tool_hint():
	var label = _statusbar.get_node(^"ToolHintLabel")
	assert_not_null(label)

	stub(_tool1, "get_status_hint").to_return("Hint 1")
	stub(_tool2, "get_status_hint").to_return("Hint 2")

	# _editor_global.data.tool = _tool1
	# assert_eq(label.text, "Hint 1")

	# _editor_global.data.tool = _tool2
	# assert_eq(label.text, "Hint 2")
