class_name DumperVehicle

static func dump(dir: String, vehicles: Array[VehicleData], data_of: Callable) -> Error:
	var result: Error = OK

	if not DirAccess.dir_exists_absolute(dir):
		result = DirAccess.make_dir_absolute(dir)
		if result != OK:
			return result

	result = _dump_attrs(dir.path_join("attrs.csv"), vehicles)
	if result != OK:
		return result

	var vehicle_count = len(vehicles)
	var digits = ceili(log(vehicle_count) / log(10))

	for index in range(vehicle_count):
		var filename = "pos_%s.csv" % str(index).pad_zeros(digits)
		var path = dir.path_join(filename)
		var vehicle = vehicles[index]

		result = _dump_pos(path, vehicle, data_of)
		if result != OK:
			return result

	return result


static func _dump_attrs(path: String, vehicles: Array[VehicleData]) -> Error:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	var header = [
		"index",
		"spawn_step",
		"die_step",
	]

	file.store_csv_line(header)

	for index in range(len(vehicles)):
		var vehicle = vehicles[index]

		var values = [
			index,
			vehicle.spawn_step,
			vehicle.die_step,
		]

		file.store_csv_line(values.map(str))

	file.close()

	return OK


static func _dump_pos(path: String, vehicle: VehicleData, data_of: Callable) -> Error:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_csv_line(["x", "y"])

	var pos_count = len(vehicle.pos_history)
	var curve: Curve2D

	for index in range(pos_count):
		if vehicle.space_history.has(index):
			var lane_id = vehicle.space_history[index]
			var lane = data_of.call(lane_id) as LaneData

			curve = Curve2D.new()

			for vertex_id in lane.vertex_ids:
				var vertex = data_of.call(vertex_id) as VertexData
				curve.add_point(vertex.pos)

		var pos = vehicle.pos_history[index]
		var vec = curve.sample_baked(pos)

		file.store_csv_line([vec.x, vec.y].map(str))

	file.close()

	return OK
