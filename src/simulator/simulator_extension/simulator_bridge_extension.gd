class_name SimulatorBridgeExtension
extends SimulatorSpaceExtension

const TRAFFIC_FACTOR = 1.0 / 100.0

var next_bridge_chooser = null

var traffic: float:
	get:
		return _traffic

var forward: float:
	get:
		return _data.forward

var width_limit: int:
	get:
		return _data.width_limit

var _traffic: float

var _prev_option_dict: Dictionary
var _next_option_dict: Dictionary

var _next_bridge_exts: Array[SimulatorBridgeExtension]
var _prev_bridge_exts: Array[SimulatorBridgeExtension]


func _init(data: BridgeData):
	super(data)


func extend(ext_of: Callable) -> void:
	super(ext_of)

	_traffic = _data.traffic * TRAFFIC_FACTOR

	_assign_ext_dict(&"_prev_option_dict", _data.prev_option_dict, ext_of)
	_assign_ext_dict(&"_next_option_dict", _data.next_option_dict, ext_of)

	_prev_bridge_exts.assign(_prev_option_dict.keys())
	_next_bridge_exts.assign(_next_option_dict.keys())
	_prev_bridge_exts.make_read_only()
	_next_bridge_exts.make_read_only()
