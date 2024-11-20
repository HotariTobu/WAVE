class_name EditorConstraintStoplight
extends EditorConstraint


func _constrain():
	bind_array(&"split_ids", &"stoplight_set")
