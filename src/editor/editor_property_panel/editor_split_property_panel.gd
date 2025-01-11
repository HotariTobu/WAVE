extends EditorPropertyPanelContent

@onready var _duration_box = $DurationBox


func get_target_content_type() -> GDScript:
	return SplitData


func _bind_cells(next_proxy: BindingSourceProxy):
	next_proxy.bind(&"duration").to(_duration_box, &"value")


func _unbind_cells(prev_proxy: BindingSourceProxy):
	prev_proxy.unbind(&"duration").from(_duration_box, &"value")


func _on_duration_box_value_changed(new_value: float):
	_editor_global.undo_redo.create_action("Change split duration")

	for source in source_proxy.sources:
		_editor_global.undo_redo.add_do_property(source, &"duration", new_value)
		_editor_global.undo_redo.add_undo_property(source, &"duration", source.duration)

	_editor_global.undo_redo.commit_action()
