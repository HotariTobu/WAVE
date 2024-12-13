class_name EditorVertexConstraint
extends EditorContentConstraint

var segments_set = ObservableSet.new()


func _constrain():
	super()

	_unlink_array_on_died(segments_set, &"vertex_ids")

	died.connect(segments_set.clear)

	segments_set.value_added.connect(_on_lane_set_changed.unbind(1))
	segments_set.value_removed.connect(_on_lane_set_changed.unbind(1))

	_include_set_on_copy(&"segments_set", true)
	_include_self_on_move()


func _on_lane_set_changed():
	dead = segments_set.size() == 0
