class_name PlayerBridgeData
extends PlayerSpaceData

const HEAD_BRIDGE_OVER_WEIGHT = 100

var start_vertex_id: StringName
var end_vertex_id: StringName


func _init(bridge: BridgeData, data_of: Callable):
	super(bridge, data_of)

	start_vertex_id = bridge.vertex_ids[0]
	end_vertex_id = bridge.vertex_ids[-1]

	if bridge.prev_option_dict.is_empty():
		var pos0 = points[1]
		var pos1 = points[0]
		var pos2 = pos0.lerp(pos1, HEAD_BRIDGE_OVER_WEIGHT)
		curve.add_point(pos2, Vector2.ZERO, Vector2.ZERO, 0)

	if bridge.next_option_dict.is_empty():
		var pos0 = points[-2]
		var pos1 = points[-1]
		var pos2 = pos0.lerp(pos1, HEAD_BRIDGE_OVER_WEIGHT)
		curve.add_point(pos2)
