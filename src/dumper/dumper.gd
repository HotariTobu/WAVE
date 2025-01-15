class_name Dumper

static func dump(dir: String, simulation: SimulationData) -> Error:
	var result: Error = OK

	if not DirAccess.dir_exists_absolute(dir):
		result = DirAccess.make_dir_absolute(dir)
		if result != OK:
			return result

	var content_dict: Dictionary

	for group_name in NetworkData.group_names:
		var contents = simulation.network[group_name]

		for content in contents:
			content_dict[content.id] = content

	content_dict.make_read_only()
	var data_of = func(content_id: StringName): return content_dict[content_id]

	result = DumperLane.dump(dir.path_join("lane"), simulation.network.lanes, data_of)
	if result != OK:
		return result

	result = DumperVehicle.dump(dir.path_join("vehicle"), simulation.vehicles, data_of)

	return result
