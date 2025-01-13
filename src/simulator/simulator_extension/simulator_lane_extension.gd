class_name SimulatorLaneExtension
extends SimulatorSpaceExtension

const TRAFFIC_FACTOR = 1.0 / 100.0
const SPEED_FACTOR = 1000.0 / 3600.0

var traffic: float
var speed_limit: float

var next_option_dict: Dictionary

var next_lane_exts: Array[SimulatorLaneExtension]
var prev_lane_exts: Array[SimulatorLaneExtension]

var choose_next_lane_ext = null
var loop_next_lane_ext_set = Set.new()

var is_closed: bool
var overflowed: float
var overflowing: float


func _init(data: LaneData):
	super(data)


func extend(ext_of: Callable) -> void:
	super(ext_of)

	traffic = _data.traffic * TRAFFIC_FACTOR
	speed_limit = _data.speed_limit * SPEED_FACTOR

	_assign_ext_dict(&"next_option_dict", &"next_option_dict", ext_of)

	next_lane_exts.assign(next_option_dict.keys())
	next_lane_exts.make_read_only()

	for next_lane_ext in next_lane_exts:
		next_lane_ext.prev_lane_exts.append(self)

	overflowed = -INF
	overflowing = -length


func update_is_blocking(_time: float):
	if agent_exts.is_empty():
		is_blocking = false
		return

	for next_lane_ext in next_lane_exts:
		if not next_lane_ext.is_blocked:
			is_blocking = true
			return

	is_blocking = false


func update_overflowed():
	overflowed = -INF

	for next_lane_ext in next_lane_exts:
		if overflowed < next_lane_ext.overflowing:
			overflowed = next_lane_ext.overflowing

func update_overflowing():
	if agent_exts.is_empty():
		overflowing = overflowed - length
	else:
		var vehicle_ext = agent_exts.back() as SimulatorVehicleExtension
		update_overflowing_by(vehicle_ext.vehicle)


func update_overflowing_by(last_vehicle: VehicleData):
	var last_pos = last_vehicle.pos_history[-1]
	overflowing = last_pos + last_vehicle.length - length
