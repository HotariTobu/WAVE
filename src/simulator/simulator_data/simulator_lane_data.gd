class_name SimulatorLaneData
extends SimulatorSpaceData

const TRAFFIC_FACTOR = 1.0 / 100.0
const SPEED_FACTOR = 1000.0 / 3600.0

var traffic: float
var speed_limit: float
var next_option_dict: Dictionary

var next_lanes: Array[SimulatorLaneData]
var prev_lanes: Array[SimulatorLaneData]

var items: Array[VehiclePos]

var overflowed: float
var overflowing: float


func assign(content: ContentData, data_of: Callable) -> void:
	super(content, data_of)
	var lane = content as LaneData
	traffic = lane.traffic * TRAFFIC_FACTOR
	speed_limit = lane.speed_limit * SPEED_FACTOR
	assign_dict(&"next_option_dict", lane.next_option_dict, data_of)

	next_lanes.assign(next_option_dict.keys())
	next_lanes.make_read_only()

	for next_lane in next_lanes:
		next_lane.prev_lanes.append(self)

	overflowed = 0.0
	overflowing = -length

func update_overflowed():
	overflowed = 0.0

	for next_lane in next_lanes:
		if overflowed < next_lane.overflowing:
			overflowed = next_lane.overflowing


func update_overflowing():
	if items.is_empty():
		overflowing = overflowed - length
	else:
		var last_item = items[-1]
		overflowing = last_item.pos + last_item.vehicle.length - length

	for prev_lane in prev_lanes:
		prev_lane.update_overflowed()


class VehiclePos:
	var vehicle: VehicleData
	var pos: float
