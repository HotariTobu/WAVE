class_name EditorSplitConstraint
extends EditorContentConstraint

var stoplight_set = ObservableSet.new()


func _constrain():
	super()

	bind_array(&"block_target_ids", &"block_source_set")

	unlink_array_on_died(stoplight_set, &"split_ids")

	died.connect(stoplight_set.clear)

	stoplight_set.value_added.connect(_on_stoplight_set_changed.unbind(1))
	stoplight_set.value_removed.connect(_on_stoplight_set_changed.unbind(1))

	_include_set_on_copy(&"stoplight_set")


func _on_stoplight_set_changed():
	dead = stoplight_set.size() == 0
