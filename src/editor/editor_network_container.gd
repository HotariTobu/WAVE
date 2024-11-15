extends Node2D

var _editor_global = editor_global

@onready var _camera = $Camera
@onready var _content_container = $ContentContainer
@onready var _tool_container = $ToolContainer


func _ready():
	_editor_global.camera = _camera

	_connect_content_db(_editor_global.lane_vertex_db, EditorLaneVertex)
	_connect_content_db(_editor_global.lane_db, EditorLaneSegments)
	_connect_content_db(_editor_global.split_db, EditorStoplightSector)
	_connect_content_db(_editor_global.stoplight_db, EditorStoplightCore)

	var tools: Array[EditorTool] = []
	for child in _tool_container.get_children():
		var tool = child as EditorTool
		tools.append(tool)

	_editor_global.data.tools = tools
	_editor_global.data.tool = tools[0]


func _connect_content_db(content_db: EditorContentDataDB, script: GDScript):
	var node_dict: Dictionary
	content_db.contents_renewed.connect(_renew_content_node.bind(node_dict, script))
	content_db.content_added.connect(_add_content_node.bind(node_dict, script))
	content_db.content_removed.connect(_remove_content_node.bind(node_dict))


func _renew_content_node(contents: Array[ContentData], node_dict: Dictionary, script: GDScript):
	for node in node_dict.values():
		_content_container.remove_child(node)

	node_dict.clear()

	for content in contents:
		_add_content_node(content, node_dict, script)


func _add_content_node(content: ContentData, node_dict: Dictionary, script: GDScript):
	var node = script.new(content)
	node_dict[content.id] = node
	_content_container.add_child(node)


func _remove_content_node(content: ContentData, node_dict: Dictionary):
	var node = node_dict.get(content.id)
	node_dict.erase(content.id)
	_content_container.remove_child(node)
