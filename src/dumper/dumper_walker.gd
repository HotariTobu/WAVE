class_name DumperWalker

const HEAD_LANE_OVER_WEIGHT = 100


static func dump(dir: String, walkers: Array[WalkerData], data_of: Callable) -> Error:
	var result: Error = OK

	if not DirAccess.dir_exists_absolute(dir):
		result = DirAccess.make_dir_absolute(dir)
		if result != OK:
			return result

	result = _dump_attrs(dir.path_join("attrs.csv"), walkers)
	if result != OK:
		return result

	var walker_count = len(walkers)
	var digits = ceili(log(walker_count) / log(10))

	for index in range(walker_count):
		var filename = "pos_%s.csv" % str(index).pad_zeros(digits)
		var path = dir.path_join(filename)
		var walker = walkers[index]

		result = _dump_pos(path, walker, data_of)
		if result != OK:
			return result

	return result


static func _dump_attrs(path: String, walkers: Array[WalkerData]) -> Error:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	var header = [
		"index",
		"spawn_step",
		"die_step",
	]

	file.store_csv_line(header)

	for index in range(len(walkers)):
		var walker = walkers[index]

		var values = [
			index,
			walker.spawn_step,
			walker.die_step,
		]

		file.store_csv_line(values.map(str))

	file.close()

	return OK


static func _dump_pos(path: String, walker: WalkerData, data_of: Callable) -> Error:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_csv_line(["x", "y", "bridge_id"])

	var pos_count = len(walker.pos_history)
	var curve: Curve2D
	var base_pos: float

	for index in range(pos_count):
		var bridge_id = ""

		if walker.space_history.has(index):
			var bridge_ids = walker.space_history[index]
			bridge_id = bridge_ids.back()
			var bridge = data_of.call(bridge_id) as BridgeData

			curve = Curve2D.new()

			for vertex_id in bridge.vertex_ids:
				var vertex = data_of.call(vertex_id) as VertexData
				curve.add_point(vertex.pos)

			if bridge.prev_option_dict.is_empty():
				var pos0 = curve.get_point_position(1)
				var pos1 = curve.get_point_position(0)
				var pos2 = pos0.lerp(pos1, HEAD_LANE_OVER_WEIGHT)
				curve.add_point(pos2)

			if bridge.next_option_dict.is_empty():
				var pos0 = curve.get_point_position(curve.point_count - 2)
				var pos1 = curve.get_point_position(curve.point_count - 1)
				var pos2 = pos0.lerp(pos1, HEAD_LANE_OVER_WEIGHT)
				curve.add_point(pos2)
				base_pos = HEAD_LANE_OVER_WEIGHT
			else:
				base_pos = 0

		var pos = walker.pos_history[index]
		var vec = curve.sample_baked(base_pos + pos)

		file.store_csv_line([vec.x, vec.y, bridge_id].map(str))

	file.close()

	return OK
