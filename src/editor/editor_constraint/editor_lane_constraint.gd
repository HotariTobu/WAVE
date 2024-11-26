class_name EditorLaneConstraint
extends EditorSpaceConstraint

var prev_lane_set = Set.new()


func _constrain():
	super()

	bind_dict(&"next_option_dict", &"prev_lane_set")

	unlink_dict_on_died(prev_lane_set, &"next_option_dict")

	died.connect(prev_lane_set.clear)