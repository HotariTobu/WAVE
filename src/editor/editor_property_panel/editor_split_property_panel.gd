extends EditorPropertyPanelContent

@onready var _duration_box = $DurationBox


func get_target_content_type() -> GDScript:
	return SplitData


func _bind_cells(next_sources: Array[EditorBindingSource]):
	var first_source = next_sources.front() as EditorBindingSource
	var unity_converter = UnifyConverter.from_property(first_source, &"duration")

	for source in next_sources:
		source.bind(&"duration").using(unity_converter).to(_duration_box, &"value")


func _unbind_cells(prev_sources: Array[EditorBindingSource]):
	for source in prev_sources:
		source.unbind(&"duration").from(_duration_box, &"value")


func _on_duration_box_value_changed(new_value: float):
	_editor_global.undo_redo.create_action("Change split duration")

	for source in sources:
		_editor_global.undo_redo.add_do_property(source, &"duration", new_value)
		_editor_global.undo_redo.add_undo_property(source, &"duration", source.duration)

	_editor_global.undo_redo.commit_action()
