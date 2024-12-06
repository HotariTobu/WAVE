class_name EditorScriptDict

static var helper = {
	&"lane_vertices": EditorLaneVertexHelper,
	&"lanes": EditorLaneHelper,
	&"splits": EditorSplitHelper,
	&"stoplights": EditorStoplightHelper,
}

static var node = {
	&"lane_vertices": EditorLaneVertex,
	&"lanes": EditorLaneSegments,
	&"splits": EditorStoplightSector,
	&"stoplights": EditorStoplightCore,
}

static var constraint = {
	&"lane_vertices": EditorLaneVertexConstraint,
	&"lanes": EditorLaneConstraint,
	&"splits": EditorSplitConstraint,
	&"stoplights": EditorStoplightConstraint,
}


static func _static_init():
	var script_dicts: Array[Dictionary]

	for property in (EditorScriptDict as Object).get_property_list():
		var usage = property[&"usage"]
		if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue

		var name = property[&"name"]
		script_dicts.append(EditorScriptDict[name])

	for script_dict in script_dicts:
		script_dict.make_read_only()

		for group_name in NetworkData.group_names:
			assert(script_dict.has(group_name))
			assert(script_dict[group_name] is GDScript)
