extends Node2D

var _editor_global = editor_global

@onready var _content_container = $ContentContainer
@onready var _tool_container = $ToolContainer


func _ready():
	for group in _editor_global.content_db.groups:
		var node_dict: Dictionary
		var script = EditorScriptDict.node[group.name]
		group.contents_renewed.connect(_renew_content_nodes.bind(node_dict, script))
		group.content_added.connect(_add_content_node.bind(node_dict, script))
		group.content_removed.connect(_remove_content_node.bind(node_dict))

	var tools: Array[EditorTool] = []
	for child in _tool_container.get_children():
		var tool = child as EditorTool
		if not tool.visible:
			continue

		tools.append(tool)

	_editor_global.source.tools = tools
	_editor_global.source.tool = tools[0]


func _renew_content_nodes(contents: Array[ContentData], node_dict: Dictionary, script: GDScript):
	for node in node_dict.values():
		node.free()

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
