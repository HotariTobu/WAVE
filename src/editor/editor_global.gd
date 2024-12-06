class_name EditorGlobal
extends Node

signal notified(property: StringName)

var content_db = EditorContentDataDB.new()
var constraint_db = EditorConstraintDB.new()
var source_db = EditorBindingSourceDB.new()

var undo_redo = UndoRedo.new()

var camera: PanZoomCamera

var source = EditorBindingSource.new(self, &"notified")

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
		var contents = _selected_item_set.to_array().map(EditorSelectable.data_of)
		return Array(contents, TYPE_OBJECT, &"RefCounted", ContentData)

var _selected_item_set = Set.new()

@onready var _content_owner = get_tree().root


func get_network() -> NetworkData:
	var network = NetworkData.new()

	for group in content_db.groups:
		network[group.name] = group.contents

	return network


func set_network(network: NetworkData):
	undo_redo.clear_history()

	for group in content_db.groups:
		group.contents = network[group.name]


func add_selected(item: EditorSelectable):
	_selected_item_set.add(item)
	item.selected = true

	if item.tree_entered.is_connected(add_selected):
		item.tree_entered.disconnect(add_selected)

	if not item.tree_exited.is_connected(remove_selected):
		item.tree_exited.connect(remove_selected.bind(item))

	notified.emit(&"selected_contents")


func add_all_selected(items: Array[EditorSelectable]):
	for item in items:
		_selected_item_set.add(item)
		item.selected = true

		if item.tree_entered.is_connected(add_selected):
			item.tree_entered.disconnect(add_selected)

		if not item.tree_exited.is_connected(remove_selected):
			item.tree_exited.connect(remove_selected.bind(item))

	notified.emit(&"selected_contents")


func remove_selected(item: EditorSelectable):
	_selected_item_set.erase(item)
	item.selected = false

	if not item.tree_entered.is_connected(add_selected):
		item.tree_entered.connect(add_selected.bind(item))

	if item.tree_exited.is_connected(remove_selected):
		item.tree_exited.disconnect(remove_selected)

	notified.emit(&"selected_contents")


func clear_selected():
	for item in _selected_item_set.to_array():
		item.selected = false

		if item.tree_exited.is_connected(remove_selected):
			item.tree_exited.disconnect(remove_selected)

	_selected_item_set.clear()

	notified.emit(&"selected_contents")


func has_selected(item: EditorSelectable):
	return _selected_item_set.has(item)


func set_content_node_owner(content_node: EditorSelectable):
	content_node.owner = _content_owner


func content_node_of(content_id: StringName) -> EditorSelectable:
	var node = _content_owner.get_node("%" + content_id)
	assert(node != null)
	return node
