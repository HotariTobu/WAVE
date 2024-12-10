class_name SimulatorBridgeData
extends SimulatorSpaceData

const TRAFFIC_FACTOR = 1.0 / 100.0

var traffic: float
var forward: float
var width_limit: int
var prev_option_dict: Dictionary
var next_option_dict: Dictionary

var next_lanes: Array[SimulatorBridgeData]
var prev_lanes: Array[SimulatorBridgeData]

var next_bridge_chooser = null

var vehicles: Array[SimulatorVehicleData]

var is_blocking: bool
var is_blocked: bool
var is_closed: bool


func assign(content: ContentData, data_of: Callable) -> void:
	super(content, data_of)
	var bridge = content as BridgeData
	traffic = bridge.traffic * TRAFFIC_FACTOR
	forward = bridge.forward
	width_limit = bridge.width_limit
	assign_dict(&"prev_option_dict", bridge.prev_option_dict, data_of)
	assign_dict(&"next_option_dict", bridge.next_option_dict, data_of)

	prev_lanes.assign(prev_option_dict.keys())
	next_lanes.assign(next_option_dict.keys())
	prev_lanes.make_read_only()
	next_lanes.make_read_only()
