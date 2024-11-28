class_name EditorStoplightConstraint
extends EditorVertexConstraint


func _constrain():
	super()

	_bind_array(&"split_ids", &"stoplight_set")

	_include_array_on_copy(&"split_ids", true)
