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


func init_params():
	var high = _data.high_speed_distance
	var half = _data.half_speed_distance
	var zero = _data.zero_speed_distance

	_distance_factor = ((half - zero) ** 2) / (high - 2 * half + zero)
	_distance_base = ((high - half) / (half - zero)) ** (1.0 / (BASE_HIGH_SPEED / 2))
	_distance_intercept = zero - _distance_factor
	_speed_slope = _data.high_speed / BASE_HIGH_SPEED
	_acceleration_slope = _data.high_speed_acceleration / BASE_HIGH_SPEED


func spawn_at(space: SimulatorSpaceData, pos: float, step: int):
	super(space, pos, step)
	over_last_pos = pos


func move_to(space: SimulatorSpaceData, step: int):
	super(space, step)
	over_last_pos += space.length


func get_preferred_distance(speed: float) -> float:
	return _distance_factor * _distance_base ** speed + _distance_intercept


func get_preferred_speed(speed_limit: float) -> float:
	return speed_limit * _speed_slope


func get_acceleration(preferred_speed: float) -> float:
	return preferred_speed * _acceleration_slope


func _enter(space: SimulatorSpaceData, step: int):
	assert(space is SimulatorLaneData)
	super(space, step)
	space.vehicles.append(self)
