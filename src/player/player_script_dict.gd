class_name PlayerScriptDict
extends BaseScriptDict

static var data = {
	&"bridge_vertices": null,
	&"bridges": PlayerBridgeData,
	&"lane_vertices": null,
	&"lanes": PlayerLaneData,
	&"splits": null,
	&"stoplights": PlayerStoplightData,
}

static var node = {
	&"bridge_vertices": null,
	&"bridges": PlayerBridge,
	&"lane_vertices": null,
	&"lanes": PlayerLane,
	&"splits": null,
	&"stoplights": PlayerStoplight,
}


static func _get_self_script() -> GDScript:
	return PlayerScriptDict
