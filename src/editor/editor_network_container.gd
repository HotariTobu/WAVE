extends Node2D

var _editor_global = editor_global

var _content_node_dict: Dictionary

@onready var _camera = $Camera
@onready var _content_container = $ContentContainer
@onready var _tool_container = $ToolContainer


func _ready():
	_editor_global.camera = _camera

	_connect_content_db(_editor_global.vertex_db, EditorLaneVertex)
	_connect_content_db(_editor_global.lane_db, EditorLaneSegments)

	var tools: Array[EditorTool] = []
	for child in _tool_container.get_children():
		var tool = child as EditorTool
		tools.append(tool)

	_editor_global.data.tools = tools
	_editor_global.data.tool = tools[0]


func _connect_content_db(content_db: EditorContentDB, script: GDScript):
	content_db.content_added.connect(_add_content_node.bind(script))
	content_db.content_removed.connect(_remove_content_node)


func _add_content_node(data: ContentData, script: GDScript):
	var node = script.new(data)
	_content_node_dict[data.id] = node
	_content_container.add_child(node)


func _remove_content_node(data: ContentData):
	var node = _content_node_dict.get(data.id)
	_content_node_dict.erase(data.id)
	_content_container.remove_child(node)
