class_name EditorLaneVertexConstraint
extends EditorVertexConstraint

var lane_set = ObservableSet.new()


func _constrain():
	super()

	unlink_array_on_died(lane_set, &"vertex_ids")

	died.connect(lane_set.clear)

	lane_set.value_added.connect(_on_lane_set_changed.unbind(1))
	lane_set.value_removed.connect(_on_lane_set_changed.unbind(1))

	_include_set_on_copy(&"lane_set", true)


func _on_lane_set_changed():
	dead = lane_set.size() == 0
