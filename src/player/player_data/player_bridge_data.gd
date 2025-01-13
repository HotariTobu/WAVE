class_name PlayerBridgeData
extends PlayerSpaceData

var start_vertex_id: StringName
var end_vertex_id: StringName

var reversed_points: PackedVector2Array


func _init(bridge: BridgeData, data_of: Callable):
	super(bridge, data_of)

	start_vertex_id = bridge.vertex_ids[0]
	end_vertex_id = bridge.vertex_ids[-1]

	reversed_points = points.duplicate()
	reversed_points.reverse()
