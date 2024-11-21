class_name SimulatorPreparedData

var network = SimulatorNetworkData.new()

var ordered_lane: Array[SimulatorLaneData]
var entry_lanes: Array[SimulatorLaneData]


func _init(should_exit: Callable, parameter: ParameterData, common_network: NetworkData):
	network.assign(common_network)

	_init_ordered_lane(should_exit)
	_init_entry_lanes()

	breakpoint


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
