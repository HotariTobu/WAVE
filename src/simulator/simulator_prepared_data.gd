class_name SimulatorPreparedData

var network = SimulatorNetworkData.new()

var ordered_lane: Array[SimulatorLaneData]
var entry_lanes: Array[SimulatorLaneData]

var vehicles: Array[VehicleData]

static var rng = RandomNumberGenerator.new()


func _init(should_exit: Callable, parameter: ParameterData, common_network: NetworkData):
	network.assign(common_network)

	_init_ordered_lane(should_exit)
	_init_entry_lanes()

	_init_vehicles(parameter)

	breakpoint


static func _static_init():
	var crypto = Crypto.new()
	var seed_num = 0
	var seed_bytes = crypto.generate_random_bytes(4)
	seed_num |= seed_bytes[0] << 24
	seed_num |= seed_bytes[1] << 16
	seed_num |= seed_bytes[2] << 8
	seed_num |= seed_bytes[3]
	rng.seed = seed_num


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


func _init_entry_lanes():
	for lane in network.lanes:
		if lane.prev_lanes.is_empty():
			entry_lanes.append(lane)


func _init_vehicles(parameter: ParameterData):
	var vehicle_count = parameter.vehicle_spawn_limit
	vehicles.resize(vehicle_count)

	var length_rng = WeightedArrayRandom.new(rng, parameter.vehicle_length_options)

	var relative_speed_rng = NormalDistributionRangeRandom.new(rng, parameter.vehicle_relative_speed_range, parameter.vehicle_relative_speed_mean)
	var max_speed_rng = NormalDistributionRangeRandom.new(rng, parameter.vehicle_max_speed_range, parameter.vehicle_max_speed_mean)

	var min_following_distance_rng = NormalDistributionRangeRandom.new(rng, parameter.vehicle_min_following_distance_range, parameter.vehicle_min_following_distance_mean)
	var max_following_distance_rng = NormalDistributionRangeRandom.new(rng, parameter.vehicle_max_following_distance_range, parameter.vehicle_max_following_distance_mean)

	for index in range(vehicle_count):
		var vehicle = VehicleData.new()
		vehicles[index] = vehicle

		vehicle.length = length_rng.next()

		vehicle.relative_speed = relative_speed_rng.next()
		vehicle.max_speed = max_speed_rng.next()

		vehicle.min_following_distance = min_following_distance_rng.next()
		vehicle.max_following_distance = max_following_distance_rng.next()


class WeightedArrayRandom:
	var _rng: RandomNumberGenerator

	var _weights: PackedFloat32Array
	var _values: PackedFloat32Array

	func _init(rng: RandomNumberGenerator, options: Array[ParameterData.RandomOption]):
		_rng = rng

		var weights = options.map(ParameterData.RandomOption.weight_of)
		var values = options.map(ParameterData.RandomOption.value_of)
		_weights = PackedFloat32Array(weights)
		_values = PackedFloat32Array(values)

	func next() -> float:
		var index = _rng.rand_weighted(_weights)
		return _values[index]


class NormalDistributionRangeRandom:
	var _rng: RandomNumberGenerator

	var _min_value: float
	var _max_value: float

	var _mean: float
	var _deviation: float

	func _init(rng: RandomNumberGenerator, range_value: ParameterData.IntRange, mean: int):
		_rng = rng

		_min_value = range_value.begin
		_max_value = range_value.end

		_mean = mean
		_deviation = minf(abs(_min_value - mean), abs(_max_value - mean))

	func next() -> float:
		var value = _rng.randfn(_mean, _deviation)
		return clampf(value, _min_value, _max_value)
