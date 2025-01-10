class_name EditorGlobal
extends Node

signal notified(property: StringName)

var content_db = EditorContentDataDB.new()
var constraint_db = EditorConstraintDB.new()
var source_db = EditorBindingSourceDB.new()

var undo_redo = UndoRedo.new()

var source = EditorBindingSource.new(self, &"notified")

var opacity: float = 1.0
var network_file_path: String

var tools: Array[EditorTool] = []

var tool: EditorTool = EditorTool.new():
	get:
		return tool
	set(next):
		var prev = tool
		if prev == next:
			return

		prev.deactivate()
		next.activate()

		tool = next

var selected_contents: Array[ContentData]:
	get:
		var contents = _selected_content_node_set.to_array().map(EditorSelectable.data_of)
		return Array(contents, TYPE_OBJECT, &"RefCounted", ContentData)

var _selected_content_node_set = ObservableSet.new()

@onready var _content_owner = get_tree().root


func _init():
	_selected_content_node_set.value_added.connect(_on_selected_content_node_added)
	_selected_content_node_set.value_removed.connect(_on_selected_content_node_removed)


func get_network() -> NetworkData:
	var network = NetworkData.new()

	for group in content_db.groups:
		network[group.name].assign(group.contents)

	return network


func set_network(network: NetworkData):
	source_db.clear()
	undo_redo.clear_history()

	for group in content_db.groups:
		group.contents = network[group.name]


func add_selected(content_node: EditorSelectable):
	_selected_content_node_set.add(content_node)
	notified.emit.call_deferred(&"selected_contents")


func add_all_selected(content_nodes: Array[EditorSelectable]):
	_selected_content_node_set.add_all(content_nodes)
	notified.emit.call_deferred(&"selected_contents")


func remove_selected(content_node: EditorSelectable):
	_selected_content_node_set.erase(content_node)
	notified.emit.call_deferred(&"selected_contents")


func clear_selected():
	_selected_content_node_set.clear()
	notified.emit.call_deferred(&"selected_contents")


func has_selected(content_node: EditorSelectable):
	return _selected_content_node_set.has(content_node)


func set_content_node_owner(content_node: EditorSelectable):
	content_node.owner = _content_owner


func content_node_of(content_id: StringName) -> EditorSelectable:
	var node = _content_owner.get_node("%" + content_id)
	assert(node != null)
	return node


func _on_selected_content_node_added(content_node: EditorSelectable):
	content_node.selected = true
	content_node.add_to_group(NodeGroup.SELECTION)

	if content_node.tree_entered.is_connected(add_selected):
		content_node.tree_entered.disconnect(add_selected)

	if not content_node.tree_exited.is_connected(remove_selected):
		content_node.tree_exited.connect(remove_selected.bind(content_node))


func _on_selected_content_node_removed(content_node: EditorSelectable):
	content_node.selected = false
	content_node.remove_from_group(NodeGroup.SELECTION)

	if not content_node.tree_entered.is_connected(add_selected):
		content_node.tree_entered.connect(add_selected.bind(content_node))

	if content_node.tree_exited.is_connected(remove_selected):
		content_node.tree_exited.disconnect(remove_selected)
