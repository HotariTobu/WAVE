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


func get_target_type():
	return EditorLaneVertex


func activate():
	super()
	var converter = ItemsToSourcesConverter.new(EditorLaneVertex)
	var filter = func(sources: Array): return sources.front() if len(sources) == 1 else null
	_editor_global.data.bind(&"selected_items").using(converter).using(filter).to(self, &"lane_vertex_source")


func deactivate():
	super()
	_editor_global.data.unbind(&"selected_items").from(self, &"lane_vertex_source")
	lane_vertex_source = null


func _bind_cells(source: EditorBindingSource):
	source.bind(&"pos").to(_pos_panel, &"value")


func _unbind_cells(source: EditorBindingSource):
	source.unbind(&"pos").from(_pos_panel, &"value")


func _on_pos_panel_value_changed(new_value):
	if lane_vertex_source == null:
		return

	_editor_global.undo_redo.create_action("Change lane vertex pos")
	_editor_global.undo_redo.add_do_property(lane_vertex_source, &"pos", new_value)
	_editor_global.undo_redo.add_undo_property(lane_vertex_source, &"pos", lane_vertex_source.pos)
	_editor_global.undo_redo.commit_action()
