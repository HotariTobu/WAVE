class_name SimulatorPreparedData

var should_exit: Callable
var parameter: ParameterData
var network = SimulatorNetworkData.new()

var rng = RandomNumberGenerator.new()

var ordered_lanes: Array[SimulatorLaneData]

var vehicle_creator: SimulatorVehicleCreator
var vehicle_entry_points: Array[VehicleEntryPoint]

var simulation = SimulationData.new()

var _inverted_step_delta: float


func _init(should_exit_callable: Callable, parameter_data: ParameterData, network_data: NetworkData):
	should_exit = should_exit_callable
	parameter = parameter_data
	network.assign(network_data)

	simulation.parameter = parameter_data
	simulation.network = network_data

	_init_rng_seed()

	_init_lanes()
	_init_ordered_lanes()

	vehicle_creator = SimulatorVehicleCreator.new(rng, parameter)
	_init_initial_vehicles()
	_init_entry_lanes()

	_inverted_step_delta = 1.0 / parameter.step_delta


func _init_rng_seed():
	if parameter.random_seed < 0:
		rng.randomize()
	else:
		rng.seed = parameter.random_seed


func _init_lanes():
	for lane in network.lanes:
		if should_exit.call():
			return

		if lane.next_lanes.is_empty():
			continue

		var random_options: Array[ParameterData.RandomOption]

		for next_lane in lane.next_option_dict:
			var next_option = lane.next_option_dict[next_lane]
			var random_option = ParameterData.RandomOption.new(next_lane, next_option.weight)
			random_options.append(random_option)

		lane.next_lane_chooser = SimulatorRandomWeightedArray.new(rng, random_options)


func _init_ordered_lanes():
	var lanes = network.lanes
	var visited_lane_set = Set.new()

	var visited = visited_lane_set.has
	var unvisited = func(lane): return not visited_lane_set.has(lane)

	while not lanes.is_empty() and not should_exit.call():
		var lane_queue: Array[SimulatorLaneData]
		var rest_lanes: Array[SimulatorLaneData]

		for lane in lanes:
			if lane.next_lanes.all(visited):
				lane_queue.append(lane)
			else:
				rest_lanes.append(lane)

		if lane_queue.is_empty():
			var lane = rest_lanes.pop_back() as SimulatorLaneData
			lane_queue.append(lane)

		while not lane_queue.is_empty() and not should_exit.call():
			var lane = lane_queue.pop_back() as SimulatorLaneData

			ordered_lanes.append(lane)
			visited_lane_set.add(lane)

			for prev_lane in lane.prev_lanes.filter(unvisited):
				if prev_lane.next_lanes.all(visited):
					lane_queue.append(prev_lane)
				else:
					rest_lanes.append(prev_lane)

		lanes = rest_lanes.filter(unvisited)

	ordered_lanes.make_read_only()


func _init_initial_vehicles():
	if not parameter.vehicle_spawn_before_start:
		return

	for lane in ordered_lanes:
		if should_exit.call():
			return

		var trial_number = roundi(lane.length * lane.traffic)

		var next_pos = maxf(lane.overflowed, 0.0)

		var secured = next_pos
		var pending_vehicles: Array[SimulatorVehicleData]

		for _i in range(trial_number):
			if lane.length < secured:
				break

			if parameter.vehicle_spawn_rate <= rng.randf():
				continue

			var vehicle = vehicle_creator.create()

			secured += vehicle.length
			pending_vehicles.append(vehicle)

		var pending_vehicle_count = len(pending_vehicles)
		var margin = maxf(lane.length - secured, 0.0)

		for index in range(pending_vehicle_count):
			var rest_count = pending_vehicle_count - index
			var gap = rng.randf_range(0.0, margin / rest_count)

			var vehicle = pending_vehicles[index]
			var pos = next_pos + gap
			vehicle.spawn_at(lane, pos, 0)

			margin -= gap
			next_pos = pos + vehicle.length

		lane.update_overflowing()
		simulation.vehicles.append_array(pending_vehicles)


func _init_entry_lanes():
	if not parameter.vehicle_spawn_after_start:
		return

	for lane in network.lanes:
		if should_exit.call():
			return

		if not lane.prev_lanes.is_empty():
			continue

		var one_per_step = lane.traffic * lane.speed_limit * parameter.step_delta
		var interval = roundi(1.0 / one_per_step)

		var entry_point = VehicleEntryPoint.new()
		entry_point.entry_lane = lane
		entry_point.interval = interval

		vehicle_entry_points.append(entry_point)

	vehicle_entry_points.make_read_only()


class VehicleEntryPoint:
	var entry_lane: SimulatorLaneData
	var interval: int

	var last_entry_step: int
