class_name EditorStoplightConstraint
extends EditorConstraint


func _constrain():
	bind_array(&"split_ids", &"stoplight_set")
