class_name BaseScriptDict


static func _static_init():
	var script = _get_self_script()
	var script_dicts: Array[Dictionary]

	for property in script.get_property_list():
		var usage = property[&"usage"]
		if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue

		var name = property[&"name"]
		script_dicts.append(script[name])

	for script_dict in script_dicts:
		script_dict.make_read_only()

		for group_name in NetworkData.group_names:
			assert(script_dict.has(group_name))
			assert(script_dict[group_name] is GDScript)


static func _get_self_script() -> GDScript:
	return BaseScript_Dict
