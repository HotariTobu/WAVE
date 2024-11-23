class_name SimulatorPreparedData

var parameter: ParameterData
var network = SimulatorNetworkData.new()

var rng = RandomNumberGenerator.new()

var ordered_lane: Array[SimulatorLaneData]

var vehicle_creator: SimulatorVehicleCreator
var vehicles: Array[VehicleData]
var vehicle_entry_points: Array[VehicleEntryPoint]


func _init(should_exit: Callable, parameter_data: ParameterData, network_data: NetworkData):
	parameter = parameter_data
	network.assign(network_data)

	_init_rng_seed()

	_init_ordered_lane(should_exit)

	vehicle_creator = SimulatorVehicleCreator.new(rng, parameter)

	_init_entry_lanes(should_exit)

	breakpoint


func add_vehicle(vehicle: VehicleData):
	vehicle.index = len(vehicles)
	vehicles.append(vehicle)


func _init_rng_seed():
	if parameter.random_seed < 0:
		rng.randomize()
	else:
		rng.seed = parameter.random_seed


func _init_ordered_lane(should_exit: Callable):
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

			ordered_lane.append(lane)
			visited_lane_set.add(lane)

			for prev_lane in lane.prev_lanes.filter(unvisited):
				if prev_lane.next_lanes.all(visited):
					lane_queue.append(prev_lane)
				else:
					rest_lanes.append(prev_lane)

		lanes = rest_lanes.filter(unvisited)

	ordered_lane.make_read_only()


func _init_initial_vehicles(should_exit: Callable):
	if not parameter.vehicle_spawn_before_start:
		return

	for lane in ordered_lane:
		if should_exit.call():
			return

		var trial_number = roundi(lane.length * lane.traffic)

		var secured = lane.overflowed
		var pending_vehicles: Array[VehicleData]

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
		var next_pos = lane.overflowed

		for index in range(pending_vehicle_count):
			var rest_count = pending_vehicle_count - index
			var gap = rng.randf_range(0.0, margin / rest_count)

			var pos = next_pos + gap
			var vehicle = pending_vehicles[index]

			var item = SimulatorLaneData.VehiclePos.new()
			item.pos = pos
			item.vehicle = vehicle
			lane.items.append(item)

			margin -= gap
			next_pos = item.pos + vehicle.length

		lane.update_overflowing()

		for vehicle in pending_vehicles:
			add_vehicle(vehicle)


func _init_entry_lanes(should_exit: Callable):
	if not parameter.vehicle_spawn_after_start:
		return

	for lane in network.lanes:
		if should_exit.call():
			return

		if not lane.prev_lanes.is_empty():
			continue

		var entry_point = VehicleEntryPoint.new()
		entry_point.entry_lane = lane
		entry_point.interval = 1.0 / (lane.traffic * lane.speed_limit * parameter.step_delta)

		vehicle_entry_points.append(entry_point)

	vehicle_entry_points.make_read_only()


class VehicleEntryPoint:
	var entry_lane: SimulatorLaneData
	var interval: int
