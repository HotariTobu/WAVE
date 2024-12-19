class_name SimulatorScriptDict
extends BaseScriptDict

static var ext = {
	&"bridge_vertices": SimulatorVertexExtension,
	&"bridges": SimulatorBridgeExtension,
	&"lane_vertices": SimulatorVertexExtension,
	&"lanes": SimulatorLaneExtension,
	&"splits": SimulatorSplitExtension,
	&"stoplights": SimulatorStoplightExtension,
}


static func _get_self_script() -> GDScript:
	return SimulatorScriptDict
