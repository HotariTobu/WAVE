class_name EditorBridgeVertexConstraint
extends EditorVertexConstraint

var bridge_set = ObservableSet.new()


func _constrain():
	super()

	_unlink_array_on_died(bridge_set, &"vertex_ids")

	died.connect(bridge_set.clear)

	bridge_set.value_added.connect(_on_bridge_set_changed.unbind(1))
	bridge_set.value_removed.connect(_on_bridge_set_changed.unbind(1))

	_include_set_on_copy(&"bridge_set", true)


func _on_bridge_set_changed():
	dead = bridge_set.size() == 0
