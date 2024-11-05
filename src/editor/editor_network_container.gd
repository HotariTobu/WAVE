extends Node2D

var _editor_global = editor_global


func _ready():
	_editor_global.camera = $Camera

	_editor_global.content_container = $ContentContainer
	_editor_global.pointer_area = $PointerArea

	var tools: Array[EditorTool] = []
	for child in $ToolContainer.get_children():
		var tool = child as EditorTool
		tools.append(tool)

	_editor_global.data.tools = tools
	_editor_global.data.tool = tools[0]


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_editor_global.pointer_area.position = get_local_mouse_position()
