class_name DumperBridge

static func dump(dir: String, bridges: Array[BridgeData], data_of: Callable) -> Error:
	var result: Error = OK

	if not DirAccess.dir_exists_absolute(dir):
		result = DirAccess.make_dir_absolute(dir)
		if result != OK:
			return result

	result = _dump_attrs(dir.path_join("attrs.csv"), bridges, data_of)

	return result


static func _dump_attrs(path: String, bridges: Array[BridgeData], data_of: Callable) -> Error:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	var header = [
		"id",
		"length",
	]

	file.store_csv_line(header)

	for bridge in bridges:
		var curve = Curve2D.new()

		for vertex_id in bridge.vertex_ids:
			var vertex = data_of.call(vertex_id) as VertexData
			curve.add_point(vertex.pos)

		var values = [
			bridge.id,
			curve.get_baked_length(),
		]

		file.store_csv_line(values.map(str))

	file.close()

	return OK
