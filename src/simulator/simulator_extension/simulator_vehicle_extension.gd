class_name SimulatorVehicleExtension
extends SimulatorAgentExtension

const BASE_HIGH_SPEED = 100.0 * 1000.0 / 3600.0

var last_distance: float

var vehicle: VehicleData:
	get:
		return _data

var _distance_factor: float
var _distance_base: float
var _distance_intercept: float
var _speed_slope: float
var _acceleration_slope: float


func _init(data: VehicleData):
	super(data)

	var high = data.high_speed_distance
	var half = data.half_speed_distance
	var zero = data.zero_speed_distance

	_distance_factor = ((half - zero) ** 2) / (high - 2 * half + zero)
	_distance_base = ((high - half) / (half - zero)) ** (1.0 / (BASE_HIGH_SPEED / 2))
	_distance_intercept = zero - _distance_factor
	_speed_slope = data.high_speed / BASE_HIGH_SPEED
	_acceleration_slope = data.high_speed_acceleration / BASE_HIGH_SPEED


func move_to(lane_exts: Array[SimulatorLaneExtension], step: int):
	var space_exts: Array[SimulatorSpaceExtension]
	space_exts.assign(lane_exts)
	_enter(space_exts, step)


func get_preferred_distance(speed: float) -> float:
	return _distance_factor * _distance_base ** speed + _distance_intercept


func get_preferred_speed(speed_limit: float) -> float:
	return speed_limit * _speed_slope


func get_acceleration(preferred_speed: float) -> float:
	return preferred_speed * _acceleration_slope


func _enter(space_exts: Array[SimulatorSpaceExtension], step: int):
	super(space_exts, step)
	var lane_ext = space_exts.back() as SimulatorLaneExtension
	lane_ext.agent_exts.append(self)
