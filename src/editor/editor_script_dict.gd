class_name EditorScriptDict
extends BaseScriptDict

static var helper = {
	&"bridge_vertices": EditorBridgeVertexHelper,
	&"bridges": EditorBridgeHelper,
	&"lane_vertices": EditorLaneVertexHelper,
	&"lanes": EditorLaneHelper,
	&"splits": EditorSplitHelper,
	&"stoplights": EditorStoplightHelper,
}

static var node = {
	&"bridge_vertices": EditorBridgeVertex,
	&"bridges": EditorBridgeSegments,
	&"lane_vertices": EditorLaneVertex,
	&"lanes": EditorLaneSegments,
	&"splits": EditorStoplightSector,
	&"stoplights": EditorStoplightCore,
}

static var constraint = {
	&"bridge_vertices": EditorBridgeVertexConstraint,
	&"bridges": EditorBridgeConstraint,
	&"lane_vertices": EditorLaneVertexConstraint,
	&"lanes": EditorLaneConstraint,
	&"splits": EditorSplitConstraint,
	&"stoplights": EditorStoplightConstraint,
}


static func _get_self_script() -> GDScript:
	return EditorScriptDict
