class_name EditorGlobal
extends Node

var data = BindingSource.new(Data.new(), &"notified")
var source_db = EditorBindingSourceDB.new()
var undo_redo = UndoRedo.new()

var camera: PanZoomCamera

var network_file_path: String

var content_data_script_dict = {
	&"lane_vertices": VertexData,
	&"lanes": LaneData,
	&"splits": SplitData,
	&"stoplights": StoplightData,
}

var content_db = EditorContentDataDB.new(content_data_script_dict.keys())

@onready var _content_owner = get_tree().root


func _init():
	content_data_script_dict.make_read_only()


func to_dict() -> Dictionary:
	var dict: Dictionary

	for group_name in content_data_script_dict:
		var group = content_db.get_group(group_name)
		var script = content_data_script_dict[group_name]
		dict[group_name] = group.contents.map(script.to_dict)

	return dict


func from_dict(dict: Dictionary):
	undo_redo.clear_history()

	for group_name in content_data_script_dict:
		var group = content_db.get_group(group_name)
		var script = content_data_script_dict[group_name]
		group.contents = dict.get(group_name, []).map(script.from_dict)


func set_content_node_owner(content_node: EditorContent):
	content_node.owner = _content_owner


func get_content_node(content_id: StringName) -> EditorContent:
	return _content_owner.get_node("%" + content_id)


class Data:
	signal notified(property: StringName)

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
			notified.emit(&"tool")

	var selected_items: Array[EditorSelectable]:
		get:
			var keys = _selected_item_set.keys()
			var item_count = len(keys)

			var items: Array[EditorSelectable] = []
			items.resize(item_count)

			for index in range(item_count):
				items[index] = keys[index] as EditorSelectable

			return items

	var _selected_item_set = {}

	func add_selected(item: EditorSelectable):
		_selected_item_set[item] = false
		item.selected = true
		notified.emit(&"selected_items")

		if item.tree_entered.is_connected(add_selected):
			item.tree_entered.disconnect(add_selected)

		if not item.tree_exited.is_connected(remove_selected):
			item.tree_exited.connect(remove_selected.bind(item))

	func add_all_selected(items: Array[EditorSelectable]):
		for item in items:
			_selected_item_set[item] = false
			item.selected = true

			if item.tree_entered.is_connected(add_selected):
				item.tree_entered.disconnect(add_selected)

			if not item.tree_exited.is_connected(remove_selected):
				item.tree_exited.connect(remove_selected.bind(item))

		notified.emit(&"selected_items")

	func remove_selected(item: EditorSelectable):
		_selected_item_set.erase(item)
		item.selected = false
		notified.emit(&"selected_items")

		if not item.tree_entered.is_connected(add_selected):
			item.tree_entered.connect(add_selected.bind(item))

		if item.tree_exited.is_connected(remove_selected):
			item.tree_exited.disconnect(remove_selected)

	func clear_selected():
		for item in _selected_item_set:
			item.selected = false

			if item.tree_exited.is_connected(remove_selected):
				item.tree_exited.disconnect(remove_selected)

		_selected_item_set.clear()
		notified.emit(&"selected_items")

	func has_selected(item: EditorSelectable):
		return item in _selected_item_set
