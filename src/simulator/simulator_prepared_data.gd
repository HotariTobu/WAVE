class_name SimulatorPreparedData

var simulation = SimulationData.new()

var _should_exit: Callable
var _parameter: ParameterData
var _ext_db: SimulatorExtensionDB

var _rng = RandomNumberGenerator.new()

var _ordered_lane_exts: Array[SimulatorLaneExtension]

var _vehicle_creator: SimulatorVehicleCreator
var _vehicle_entry_points: Array[VehicleEntryPoint]

var _block_source_exts: Array[SimulatorContentExtension]
var _block_target_exts: Array[SimulatorContentExtension]
var _closable_lane_exts: Array[SimulatorLaneExtension]

var _inverted_step_delta: float

var _instances: Array


func _init(should_exit: Callable, parameter: ParameterData, network: NetworkData):
	simulation.parameter = parameter
	simulation.network = network

	_should_exit = should_exit
	_parameter = parameter
	_ext_db = SimulatorExtensionDB.new(network)

	_init_rng_seed()

	_init_lane_exts()
	_init_ordered_lane_exts()

	_vehicle_creator = SimulatorVehicleCreator.new(_rng, parameter)
	_init_initial_vehicles()
	_init_vehicle_entry_points()

	_init_block_source_exts()
	_init_block_target_exts()

	_inverted_step_delta = 1.0 / parameter.step_delta


func _init_rng_seed():
	if _parameter.random_seed < 0:
		_rng.randomize()
	else:
		_rng.seed = _parameter.random_seed


func _init_lane_exts():
	for lane_ext in _ext_db.lanes:
		if _should_exit.call():
			return

		lane_ext.prev_lane_exts.make_read_only()

		var next_lane_count = len(lane_ext.next_lane_exts)
		if next_lane_count == 0:
			continue

		if next_lane_count == 1:
			var next_lane_ext = lane_ext.next_lane_exts.front()
			lane_ext.choose_next_lane_ext = func(): return next_lane_ext
			continue

		var next_lane_ext_chooser = SimulatorRandomWeightedArray.new(_rng)
		_instances.append(next_lane_ext_chooser)

		for next_lane_ext in lane_ext.next_option_dict:
			var next_option = lane_ext.next_option_dict[next_lane_ext]
			next_lane_ext_chooser.add_option(next_option.weight, next_lane_ext)

		lane_ext.choose_next_lane_ext = next_lane_ext_chooser.next


func _init_ordered_lane_exts():
	var lane_exts = _ext_db.lanes
	var visited_lane_ext_set = Set.new()

	var visited = visited_lane_ext_set.has
	var unvisited = func(lane_ext): return not visited_lane_ext_set.has(lane_ext)

	while not lane_exts.is_empty() and not _should_exit.call():
		var lane_ext_stack: Array[SimulatorLaneExtension]
		var rest_lane_exts: Array[SimulatorLaneExtension]

		for lane_ext in lane_exts:
			if lane_ext.next_lane_exts.all(visited):
				lane_ext_stack.append(lane_ext)
			else:
				rest_lane_exts.append(lane_ext)

		if lane_ext_stack.is_empty():
			var lane_ext = rest_lane_exts.pop_back() as SimulatorLaneExtension
			lane_ext_stack.append(lane_ext)

			var loop_next_lanes = lane_ext.next_lane_exts.filter(unvisited)
			lane_ext.loop_next_lane_ext_set.add_all(loop_next_lanes)

		while not lane_ext_stack.is_empty() and not _should_exit.call():
			var lane_ext = lane_ext_stack.pop_back() as SimulatorLaneExtension

			_ordered_lane_exts.append(lane_ext)
			visited_lane_ext_set.add(lane_ext)

			for prev_lane_ext in lane_ext.prev_lane_exts.filter(unvisited):
				if prev_lane_ext.next_lane_exts.all(visited):
					lane_ext_stack.append(prev_lane_ext)
				else:
					rest_lane_exts.append(prev_lane_ext)

		lane_exts = rest_lane_exts

	_ordered_lane_exts.make_read_only()


func _init_initial_vehicles():
	if not _parameter.vehicle_spawn_before_start:
		return

	for lane_ext in _ordered_lane_exts:
		if _should_exit.call():
			return

		var trial_number = roundi(lane_ext.length * lane_ext.traffic)

		var next_pos = maxf(lane_ext.overflowed, 0.0)

		var secured_pos = next_pos
		var pending_vehicle_exts: Array[SimulatorVehicleExtension]

		for _i in range(trial_number):
			if lane_ext.length < secured_pos:
				break

			if _parameter.vehicle_spawn_rate <= _rng.randf():
				continue

			var vehicle_ext = _vehicle_creator.create()

			secured_pos += vehicle_ext.vehicle.length
			pending_vehicle_exts.append(vehicle_ext)

		var pending_vehicle_count = len(pending_vehicle_exts)
		var margin = maxf(lane_ext.length - secured_pos, 0.0)

		for index in range(pending_vehicle_count):
			var rest_count = pending_vehicle_count - index
			var gap = _rng.randf_range(0.0, margin / rest_count)

			var vehicle_ext = pending_vehicle_exts[index]
			var pos = next_pos + gap
			vehicle_ext.spawn_at(lane_ext, pos, 0)
			simulation.vehicles.append(vehicle_ext.vehicle)

			margin -= gap
			next_pos = pos + vehicle_ext.vehicle.length

		lane_ext.update_overflowing()


func _init_vehicle_entry_points():
	if not _parameter.vehicle_spawn_after_start:
		return

	for lane_ext in _ext_db.lanes:
		if _should_exit.call():
			return

		if not lane_ext.prev_lane_exts.is_empty():
			continue

		var one_per_step = lane_ext.traffic * lane_ext.speed_limit * _parameter.step_delta
		var interval = roundi(1.0 / one_per_step)

		var entry_point = VehicleEntryPoint.new()
		entry_point.entry_lane_ext = lane_ext
		entry_point.interval = interval

		_vehicle_entry_points.append(entry_point)

	_vehicle_entry_points.make_read_only()


func _init_block_source_exts():
	if _should_exit.call():
		return

	_block_source_exts.append_array(_ext_db.stoplights.filter(_has_split))
	_block_source_exts.append_array(_ordered_lane_exts.filter(_has_block_target))


func _init_block_target_exts():
	if _should_exit.call():
		return

	var block_target_lane_exts = _ordered_lane_exts.filter(_has_block_source)
	_block_target_exts.append_array(block_target_lane_exts)

	for block_target_ext in _block_target_exts:
		simulation.block_history[block_target_ext.id] = PackedInt32Array()

	var closable_lane_ext_set = Set.new()

	for lane_ext in block_target_lane_exts:
		if _should_exit.call():
			return

		closable_lane_ext_set.add_all(lane_ext.prev_lane_exts)

	_closable_lane_exts.assign(closable_lane_ext_set.to_array())


static func _has_split(stoplight_ext: SimulatorStoplightExtension):
	return not stoplight_ext.split_exts.is_empty()


static func _has_block_target(content: SimulatorContentExtension):
	return not content.block_target_exts.is_empty()


static func _has_block_source(content: SimulatorContentExtension):
	return not content.block_source_exts.is_empty()


class VehicleEntryPoint:
	var entry_lane_ext: SimulatorLaneExtension
	var interval: int

	var last_entry_step: int
