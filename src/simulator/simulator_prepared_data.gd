class_name SimulatorPreparedData

var simulation = SimulationData.new()

var _should_exit: Callable
var _parameter: ParameterData
var _ext_db: SimulatorExtensionDB

var _rng = RandomNumberGenerator.new()

var _forward_ordered_bridge_exts: Array[SimulatorBridgeExtension]
var _backward_ordered_bridge_exts: Array[SimulatorBridgeExtension]
var _ordered_lane_exts: Array[SimulatorLaneExtension]

var _walker_creator: SimulatorWalkerCreator
var _walker_entry_points: Array[EntryPoint]

var _vehicle_creator: SimulatorVehicleCreator
var _vehicle_entry_points: Array[EntryPoint]

var _block_source_exts: Array[SimulatorContentExtension]
var _block_target_exts: Array[SimulatorContentExtension]
var _closable_bridge_exts: Array[SimulatorBridgeExtension]
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

	_init_bridge_exts()
	_init_forward_ordered_bridge_exts()
	_init_backward_ordered_bridge_exts()

	_init_lane_exts()
	_init_ordered_lane_exts()

	_walker_creator = SimulatorWalkerCreator.new(_rng, parameter.walker_spawn_parameters)
	_init_initial_walkers()
	_init_walker_entry_points()

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


func _init_bridge_exts():
	for bridge_ext in _ext_db.bridges:
		if _should_exit.call():
			return

		var prev_bridge_count = len(bridge_ext.prev_bridge_exts)
		if prev_bridge_count == 1:
			var prev_bridge_ext = bridge_ext.prev_bridge_exts.front()
			bridge_ext.choose_prev_bridge_ext = func(): return prev_bridge_ext

		elif prev_bridge_count > 1:
			var prev_bridge_ext_chooser = SimulatorRandomWeightedArray.new(_rng)
			_instances.append(prev_bridge_ext_chooser)

			for prev_bridge_ext in bridge_ext.prev_option_dict:
				var prev_option = bridge_ext.prev_option_dict[prev_bridge_ext]
				prev_bridge_ext_chooser.add_option(prev_option.weight, prev_bridge_ext)

			bridge_ext.choose_prev_bridge_ext = prev_bridge_ext_chooser.next

		var next_bridge_count = len(bridge_ext.next_bridge_exts)
		if next_bridge_count == 1:
			var next_bridge_ext = bridge_ext.next_bridge_exts.front()
			bridge_ext.choose_next_bridge_ext = func(): return next_bridge_ext

		elif next_bridge_count > 1:
			var next_bridge_ext_chooser = SimulatorRandomWeightedArray.new(_rng)
			_instances.append(next_bridge_ext_chooser)

			for next_bridge_ext in bridge_ext.next_option_dict:
				var next_option = bridge_ext.next_option_dict[next_bridge_ext]
				next_bridge_ext_chooser.add_option(next_option.weight, next_bridge_ext)

			bridge_ext.choose_next_bridge_ext = next_bridge_ext_chooser.next


func _init_forward_ordered_bridge_exts():
	var bridge_exts = _ext_db.bridges
	var visited_bridge_ext_set = Set.new()

	var visited = visited_bridge_ext_set.has
	var unvisited = func(bridge_ext): return not visited_bridge_ext_set.has(bridge_ext)

	while not bridge_exts.is_empty() and not _should_exit.call():
		var bridge_ext_stack: Array[SimulatorBridgeExtension]
		var rest_bridge_exts: Array[SimulatorBridgeExtension]

		for bridge_ext in bridge_exts:
			if bridge_ext.next_bridge_exts.all(visited):
				bridge_ext_stack.append(bridge_ext)
			else:
				rest_bridge_exts.append(bridge_ext)

		if bridge_ext_stack.is_empty():
			var bridge_ext = rest_bridge_exts.pop_back() as SimulatorBridgeExtension
			bridge_ext_stack.append(bridge_ext)

			var loop_next_bridges = bridge_ext.next_bridge_exts.filter(unvisited)
			bridge_ext.loop_next_bridge_ext_set.add_all(loop_next_bridges)

		while not bridge_ext_stack.is_empty() and not _should_exit.call():
			var bridge_ext = bridge_ext_stack.pop_back() as SimulatorBridgeExtension

			_forward_ordered_bridge_exts.append(bridge_ext)
			visited_bridge_ext_set.add(bridge_ext)

			for prev_bridge_ext in bridge_ext.prev_bridge_exts.filter(unvisited):
				if prev_bridge_ext.next_bridge_exts.all(visited):
					bridge_ext_stack.append(prev_bridge_ext)
				else:
					rest_bridge_exts.append(prev_bridge_ext)

		bridge_exts = rest_bridge_exts.filter(unvisited)

	_forward_ordered_bridge_exts.make_read_only()

	assert(len(_ext_db.bridges) == len(_forward_ordered_bridge_exts) and len(_forward_ordered_bridge_exts) == Set.from_array(_forward_ordered_bridge_exts).size())


func _init_backward_ordered_bridge_exts():
	var bridge_exts = _ext_db.bridges
	var visited_bridge_ext_set = Set.new()

	var visited = visited_bridge_ext_set.has
	var unvisited = func(bridge_ext): return not visited_bridge_ext_set.has(bridge_ext)

	while not bridge_exts.is_empty() and not _should_exit.call():
		var bridge_ext_stack: Array[SimulatorBridgeExtension]
		var rest_bridge_exts: Array[SimulatorBridgeExtension]

		for bridge_ext in bridge_exts:
			if bridge_ext.prev_bridge_exts.all(visited):
				bridge_ext_stack.append(bridge_ext)
			else:
				rest_bridge_exts.append(bridge_ext)

		if bridge_ext_stack.is_empty():
			var bridge_ext = rest_bridge_exts.pop_back() as SimulatorBridgeExtension
			bridge_ext_stack.append(bridge_ext)

			var loop_prev_bridges = bridge_ext.prev_bridge_exts.filter(unvisited)
			bridge_ext.loop_prev_bridge_ext_set.add_all(loop_prev_bridges)

		while not bridge_ext_stack.is_empty() and not _should_exit.call():
			var bridge_ext = bridge_ext_stack.pop_back() as SimulatorBridgeExtension

			_backward_ordered_bridge_exts.append(bridge_ext)
			visited_bridge_ext_set.add(bridge_ext)

			for next_bridge_ext in bridge_ext.next_bridge_exts.filter(unvisited):
				if next_bridge_ext.prev_bridge_exts.all(visited):
					bridge_ext_stack.append(next_bridge_ext)
				else:
					rest_bridge_exts.append(next_bridge_ext)

		bridge_exts = rest_bridge_exts.filter(unvisited)

	_backward_ordered_bridge_exts.make_read_only()

	assert(len(_ext_db.bridges) == len(_backward_ordered_bridge_exts) and len(_backward_ordered_bridge_exts) == Set.from_array(_backward_ordered_bridge_exts).size())


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

		lane_exts = rest_lane_exts.filter(unvisited)

	_ordered_lane_exts.make_read_only()

	assert(len(_ext_db.lanes) == len(_ordered_lane_exts) and len(_ordered_lane_exts) == Set.from_array(_ordered_lane_exts).size())


func _init_initial_walkers():
	if not _parameter.walker_spawn_before_start:
		return

	var max_walker_diameter = 0.0
	for walker_spawn_parameter in _parameter.walker_spawn_parameters:
		var diameter =  walker_spawn_parameter.radius * 2
		if max_walker_diameter < diameter:
			max_walker_diameter = diameter

	for bridge_ext in _ext_db.bridges:
		if _should_exit.call():
			return

		var trial_number = roundi(bridge_ext.length * bridge_ext.traffic)

		for _i in range(bridge_ext.width_limit):
			var next_pos = 0.0

			var secured_pos = next_pos
			var pending_walker_exts: Array[SimulatorWalkerExtension]

			while trial_number > 0:
				trial_number -= 1

				if bridge_ext.length < secured_pos + max_walker_diameter:
					break

				if _rng.randf() >= _parameter.walker_spawn_rate:
					continue

				var walker_ext = _walker_creator.create()
				walker_ext.forward = _rng.randf() < bridge_ext.bridge.forward_rate

				secured_pos += walker_ext.diameter
				pending_walker_exts.append(walker_ext)

			var pending_walker_count = len(pending_walker_exts)
			var margin = maxf(bridge_ext.length - (secured_pos + max_walker_diameter), 0.0)

			for index in range(pending_walker_count):
				var rest_count = pending_walker_count - index
				var gap = _rng.randf_range(0.0, margin / rest_count)

				var walker_ext = pending_walker_exts[index]
				var pos = next_pos + gap
				walker_ext.spawn_at(bridge_ext, pos, 0)
				simulation.walkers.append(walker_ext.walker)

				margin -= gap
				next_pos = pos + walker_ext.diameter

		bridge_ext.agent_exts.sort_custom(_comp_agent_exts)
		# bridge_ext.init_tails_array()


func _init_walker_entry_points():
	if not _parameter.walker_spawn_after_start:
		return

	var sum_walker_weighted_speed_mean = 0.0
	var sum_walker_weight = 0.0
	for walker_spawn_parameter in _parameter.walker_spawn_parameters:
		sum_walker_weighted_speed_mean += walker_spawn_parameter.speed_mean * walker_spawn_parameter.weight
		sum_walker_weight += walker_spawn_parameter.weight
	var average_walker_speed = sum_walker_weighted_speed_mean / sum_walker_weight
	average_walker_speed *= SimulatorWalkerCreator.SPEED_FACTOR

	for bridge_ext in _ext_db.bridges:
		if _should_exit.call():
			return

		if not bridge_ext.prev_bridge_exts.is_empty() and not bridge_ext.next_bridge_exts.is_empty():
			continue

		var one_per_step = bridge_ext.traffic * average_walker_speed * _parameter.step_delta
		var interval = roundi(1.0 / one_per_step)

		var entry_point = EntryPoint.new()
		entry_point.entry_space_ext = bridge_ext
		entry_point.interval = interval
		entry_point.next_entry_step = _rng.randi_range(0, _parameter.max_entry_step_offset)

		_walker_entry_points.append(entry_point)

	_walker_entry_points.make_read_only()


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

			if _rng.randf() >= _parameter.vehicle_spawn_rate:
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

		var entry_point = EntryPoint.new()
		entry_point.entry_space_ext = lane_ext
		entry_point.interval = interval
		entry_point.next_entry_step = _rng.randi_range(0, _parameter.max_entry_step_offset)

		_vehicle_entry_points.append(entry_point)

	_vehicle_entry_points.make_read_only()


func _init_block_source_exts():
	if _should_exit.call():
		return

	_block_source_exts.append_array(_ext_db.bridges.filter(_has_block_target))
	_block_source_exts.append_array(_ext_db.lanes.filter(_has_block_target))
	_block_source_exts.append_array(_ext_db.stoplights.filter(_has_split))


func _init_block_target_exts():
	if _should_exit.call():
		return

	var block_target_bridge_exts = _ext_db.bridges.filter(_has_block_source)
	_block_target_exts.append_array(block_target_bridge_exts)

	var block_target_lane_exts = _ext_db.lanes.filter(_has_block_source)
	_block_target_exts.append_array(block_target_lane_exts)

	for block_target_ext in _block_target_exts:
		simulation.block_history[block_target_ext.id] = PackedInt32Array()

	var closable_bridge_ext_set = Set.new()

	for bridge_ext in block_target_bridge_exts:
		if _should_exit.call():
			return

		closable_bridge_ext_set.add_all(bridge_ext.prev_bridge_exts)
		closable_bridge_ext_set.add_all(bridge_ext.next_bridge_exts)

	for bridge_ext in closable_bridge_ext_set.to_array():
		if not bridge_ext.prev_bridge_exts.all(_has_block_source) and not bridge_ext.next_bridge_exts.all(_has_block_source):
			continue

		_closable_bridge_exts.append(bridge_ext)

	var closable_lane_ext_set = Set.new()

	for lane_ext in block_target_lane_exts:
		if _should_exit.call():
			return

		closable_lane_ext_set.add_all(lane_ext.prev_lane_exts)

	for lane_ext in closable_lane_ext_set.to_array():
		if not lane_ext.next_lane_exts.all(_has_block_source):
			continue

		_closable_lane_exts.append(lane_ext)


static func _comp_agent_exts(a: SimulatorAgentExtension, b: SimulatorAgentExtension) -> bool:
	return a.agent.pos_history[-1] < b.agent.pos_history[-1]


static func _has_block_target(content: SimulatorContentExtension):
	return not content.block_target_exts.is_empty()


static func _has_block_source(content: SimulatorContentExtension):
	return not content.block_source_exts.is_empty()


static func _has_split(stoplight_ext: SimulatorStoplightExtension):
	return not stoplight_ext.split_exts.is_empty()


class EntryPoint:
	var entry_space_ext: SimulatorSpaceExtension
	var interval: int

	var next_entry_step: int
