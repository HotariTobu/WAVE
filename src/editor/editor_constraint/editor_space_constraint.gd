class_name EditorSpaceConstraint
extends EditorSegmentsConstraint

var block_source_set = Set.new()


func _constrain():
	super()

	bind_array(&"block_target_ids", &"block_source_set")

	unlink_array_on_died(block_source_set, &"block_target_ids")

	died.connect(block_source_set.clear)
