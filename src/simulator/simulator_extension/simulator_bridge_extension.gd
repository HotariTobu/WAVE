class_name SimulatorBridgeExtension
extends SimulatorSpaceExtension

const TRAFFIC_FACTOR = 1.0 / 100.0

var traffic: float
var width_limit: float

var prev_option_dict: Dictionary
var next_option_dict: Dictionary

var next_bridge_exts: Array[SimulatorBridgeExtension]
var prev_bridge_exts: Array[SimulatorBridgeExtension]

var choose_prev_bridge_ext = null
var choose_next_bridge_ext = null
var loop_prev_bridge_ext_set = Set.new()
var loop_next_bridge_ext_set = Set.new()

var forward_is_closed: bool
var backward_is_closed: bool

var bridge: BridgeData:
	get:
		return _data


func _init(data: BridgeData):
	super(data)


func extend(ext_of: Callable) -> void:
	super(ext_of)

	traffic = _data.traffic * TRAFFIC_FACTOR
	width_limit = _data.width_limit

	_assign_ext_dict(&"prev_option_dict", &"prev_option_dict", ext_of)
	_assign_ext_dict(&"next_option_dict", &"next_option_dict", ext_of)

	prev_bridge_exts.assign(prev_option_dict.keys())
	next_bridge_exts.assign(next_option_dict.keys())
	prev_bridge_exts.make_read_only()
	next_bridge_exts.make_read_only()


func update_is_blocking(_time: float):
	is_blocking = not agent_exts.is_empty()
