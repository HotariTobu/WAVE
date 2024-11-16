extends EditorPropertyPanelContent

var lane_vertex_source: EditorBindingSource:
	get:
		return lane_vertex_source
	set(next):
		var prev = lane_vertex_source

		if prev != null:
			_unbind_cells(prev)

		if next != null:
			_bind_cells(next)

		lane_vertex_source = next

var _editor_global = editor_global

@onready var _pos_panel = $PosPanel


func _ready():
	$PosPanel/XRow/Label.set_deferred(&'size_flags_horizontal', Control.SIZE_FILL)
	$PosPanel/YRow/Label.set_deferred(&'size_flags_horizontal', Control.SIZE_FILL)

func get_target_type():
	return EditorLaneVertex


func activate():
	super()
	_editor_global.data.bind(&"selected_items").using(_get_lane_vertex_source).to(self, &"lane_vertex_source")


func deactivate():
	super()
	_editor_global.data.unbind(&"selected_items").from(self, &"lane_vertex_source")
	lane_vertex_source = null


func _get_lane_vertex_source(items: Array[EditorSelectable]) -> EditorBindingSource:
	if len(items) != 1:
		return null
		
	var vertex_node = items.front() as EditorLaneVertex
	if vertex_node == null:
		return null
		
	var vertex = vertex_node.data
	var source = _editor_global.source_db.get_or_add(vertex)
	return source


func _bind_cells(source: EditorBindingSource):
	source.bind(&"pos").to(_pos_panel, &"value")

func _unbind_cells(source: EditorBindingSource):
	source.unbind(&"pos").from(_pos_panel, &"value")

func _on_pos_panel_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change lane vertex pos")
	_editor_global.undo_redo.add_do_property(lane_vertex_source, &"pos", new_value)
	_editor_global.undo_redo.add_undo_property(lane_vertex_source, &"pos", lane_vertex_source.pos)
	_editor_global.undo_redo.commit_action()
