class_name EditorStoplightConstraint
extends EditorVertexConstraint


func _constrain():
	super()

	bind_array(&"split_ids", &"stoplight_set")
