class_name SimulatorVehicleExtension
extends SimulatorAgentExtension

const BASE_HIGH_SPEED = 100.0 * 1000.0 / 3600.0

var last_distance: float
var over_last_pos: float

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


func spawn_at(space_ext: SimulatorSpaceExtension, pos: float, step: int):
	super(space_ext, pos, step)
	over_last_pos = pos


func move_to(space_ext: SimulatorSpaceExtension, step: int):
	super(space_ext, step)
	over_last_pos += space_ext.length


func get_preferred_distance(speed: float) -> float:
	return _distance_factor * _distance_base ** speed + _distance_intercept


func get_preferred_speed(speed_limit: float) -> float:
	return speed_limit * _speed_slope


func get_acceleration(preferred_speed: float) -> float:
	return preferred_speed * _acceleration_slope
