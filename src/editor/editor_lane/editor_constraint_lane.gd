class_name EditorConstraintLane
extends EditorConstraint

var block_source_set = Set.new()
var prev_lane_set = Set.new()


func _constrain():
	bind_array(&"vertex_ids", &"lane_set")
	bind_array(&"block_target_ids", &"block_source_set")
	bind_dict(&"next_option_dict", &"prev_lane_set")

	unlink_array_on_died(block_source_set, &"block_target_ids")
	unlink_dict_on_died(prev_lane_set, &"next_option_dict")

	died.connect(_on_dead)

	_data_source.add_callback(&"vertex_ids", _on_vertex_ids_changed)


func _on_dead():
	block_source_set.clear()
	prev_lane_set.clear()


func _on_vertex_ids_changed():
	var vertex_count = len(_data.vertex_ids)
	dead = vertex_count < 2
