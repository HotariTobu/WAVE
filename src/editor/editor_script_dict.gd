class_name EditorScriptDict

static var helper = {
	&"lane_vertices": EditorLaneVertexHelper,
	&"lanes": EditorLaneHelper,
	&"splits": EditorSplitHelper,
	&"stoplights": EditorStoplightHelper,
}


static func _static_init():
	var script_dicts: Array[Dictionary] = [
		helper,
	]

	for script_dict in script_dicts:
		script_dict.make_read_only()

		for group_name in NetworkData.group_names:
			assert(script_dict.has(group_name))
			assert(script_dict[group_name] is GDScript)
