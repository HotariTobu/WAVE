class_name SimulatorVehicleData
extends VehicleData

const BASE_HIGH_SPEED = 100.0 * 1000.0 / 3600.0

var last_distance: float
var over_last_pos: float

var _distance_factor: float
var _distance_base: float
var _speed_slope: float
var _acceleration_slope: float


func init_params():
	_distance_factor = ((half_speed_distance - zero_speed_distance) ** 2) / (high_speed_distance - 2 * half_speed_distance + zero_speed_distance)
	_distance_base = ((high_speed_distance - half_speed_distance) / (half_speed_distance - zero_speed_distance)) ** (1.0 / (BASE_HIGH_SPEED / 2))
	_speed_slope = high_speed / BASE_HIGH_SPEED
	_acceleration_slope = high_speed_acceleration / BASE_HIGH_SPEED


func spawn_at(lane: SimulatorLaneData, pos: float, step: int):
	over_last_pos = pos
	spawn_step = step
	die_step = -1
	pos_history.append(pos)
	_enter(lane, step - 1)


func move_to(lane: SimulatorLaneData, step: int):
	over_last_pos += lane.length
	pos_history[-1] += lane.length
	_enter(lane, step)


func die(step: int):
	die_step = step + 1


func get_preferred_distance(speed: float) -> float:
	return _distance_factor * _distance_base ** speed + zero_speed_distance - _distance_factor


func get_preferred_speed(speed_limit: float) -> float:
	return speed_limit * _speed_slope


func get_acceleration(preferred_speed: float) -> float:
	return preferred_speed * _acceleration_slope


func _enter(lane: SimulatorLaneData, step: int):
	assert(len(pos_history) - 1 == step - spawn_step + 1)
	space_history[step - spawn_step + 1] = lane.id
	lane.vehicles.append(self)
