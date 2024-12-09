class_name EditorBridgeConstraint
extends EditorSpaceConstraint

var prev_bridge_set = Set.new()
var next_bridge_set = Set.new()


func _constrain():
	super()

	_bind_dict(&"next_option_dict", &"prev_bridge_set")
	_bind_dict(&"prev_option_dict", &"next_bridge_set")

	_unlink_dict_on_died(prev_bridge_set, &"next_option_dict")
	_unlink_dict_on_died(next_bridge_set, &"prev_option_dict")

	died.connect(prev_bridge_set.clear)
	died.connect(next_bridge_set.clear)
