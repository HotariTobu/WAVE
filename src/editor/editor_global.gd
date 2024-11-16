class_name EditorGlobal
extends Node

var data = BindingSource.new(Data.new(), &"notified")
var source_db = EditorBindingSourceDB.new()
var undo_redo = UndoRedo.new()

var camera: PanZoomCamera

var network_file_path: String

var lane_vertex_db = EditorContentDataDB.new()
var lane_db = EditorContentDataDB.new()
var split_db = EditorContentDataDB.new()
var stoplight_db = EditorContentDataDB.new()

@onready var _content_owner = get_tree().root


func to_dict() -> Dictionary:
	return {
		&"lane_vertices": lane_vertex_db.contents.map(VertexData.to_dict),
		&"lanes": lane_db.contents.map(LaneData.to_dict),
		&"splits": split_db.contents.map(SplitData.to_dict),
		&"stoplights": stoplight_db.contents.map(StoplightData.to_dict),
	}


func from_dict(dict: Dictionary):
	undo_redo.clear_history()

	lane_vertex_db.contents = dict.get(&"lane_vertices", []).map(VertexData.from_dict)
	lane_db.contents = dict.get(&"lanes", []).map(LaneData.from_dict)
	split_db.contents = dict.get(&"splits", []).map(SplitData.from_dict)
	stoplight_db.contents = dict.get(&"stoplights", []).map(StoplightData.from_dict)


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
