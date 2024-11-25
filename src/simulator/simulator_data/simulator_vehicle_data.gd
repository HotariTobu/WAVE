class_name SimulatorVehicleData
extends VehicleData

const BASE_HIGH_SPEED = 100.0 * 1000.0 / 3600.0

var over_last_pos: float

var _inverted_max_speed: float
var _distance_slope: float
var _speed_slope: float


func init_params():
	_inverted_max_speed = 1.0 / max_speed
	_distance_slope = (high_speed_distance - low_speed_distance) / BASE_HIGH_SPEED
	_speed_slope = base_speed / BASE_HIGH_SPEED


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


func get_speed_rate(speed: float) -> float:
	return speed * _inverted_max_speed


func get_preferred_distance(speed: float) -> float:
	return speed * _distance_slope + low_speed_distance


func get_preferred_speed(speed_limit: float) -> float:
	return speed_limit * _speed_slope


func _enter(lane: SimulatorLaneData, step: int):
	assert(len(pos_history) - 1 == step - spawn_step + 1)
	lane_history[step - spawn_step + 1] = lane.id
	lane.vehicles.append(self)
