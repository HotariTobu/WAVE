extends GutTest

const NetworkContainerScene = preload("res://src/editor/editor_network_container.tscn")

var _editor_global: EditorGlobal
var _network_container

var _tool1: EditorTool
var _tool2: EditorTool

var _sender


func before_each():
	_editor_global = autofree(EditorGlobal.new())

	_network_container = NetworkContainerScene.instantiate()
	_network_container._editor_global = _editor_global

	var tool_container = _network_container.get_node(^"ToolContainer") as Node

	for child in tool_container.get_children():
		child.free()

	_tool1 = EditorTool.new()
	_tool2 = EditorTool.new()
	tool_container.add_child(_tool1)
	tool_container.add_child(_tool2)

	add_child_autofree(_network_container)
	_sender = InputSender.new(_network_container)


func test_ready():
	assert_not_null(_editor_global.camera)

	assert_not_null(_editor_global.bridge_container)
	assert_not_null(_editor_global.lane_container)
	assert_not_null(_editor_global.pointer_area)

	assert_eq(_editor_global.data.tool, _tool1)
	assert_eq(_editor_global.data.tools, [_tool1, _tool2])


func test_pointer_position():
	pass_test("NOTE: Cannot define the test because cannot stub mouse pos.")
