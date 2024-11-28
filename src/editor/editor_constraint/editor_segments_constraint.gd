class_name EditorSegmentsConstraint
extends EditorContentConstraint


func _constrain():
	super()

	_bind_array(&"vertex_ids", &"lane_set")

	_data_source.add_callback(&"vertex_ids", _on_vertex_ids_changed)

	_include_array_on_copy(&"vertex_ids", false)
	_include_array_on_move(&"vertex_ids")


func _on_vertex_ids_changed():
	var vertex_count = len(_data.vertex_ids)
	dead = vertex_count < 2
