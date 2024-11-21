class_name SimulatorLaneData
extends SimulatorSpaceData

var speed_limit: int
var next_option_dict: Dictionary

var next_lanes: Array[SimulatorLaneData]
var prev_lanes: Array[SimulatorLaneData]


func assign(content: ContentData, data_of: Callable) -> void:
	super(content, data_of)
	var lane = content as LaneData
	speed_limit = lane.speed_limit
	assign_dict(&"next_option_dict", lane.next_option_dict, data_of)

	next_lanes.assign(next_option_dict.keys())
	next_lanes.make_read_only()
	
	for next_lane in next_lanes:
		next_lane.prev_lanes.append(self)
