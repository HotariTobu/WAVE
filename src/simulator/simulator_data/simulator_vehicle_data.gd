class_name SimulatorVehicleData
extends VehicleData

var preferred_speed_getter: Callable

var over_last_pos: float

var _gradual_speed_slope: float
var _rapid_speed_slope: float
var _inverted_max_speed: float
var _rest_distance: float


func init_params():
	_gradual_speed_slope = condition_speed / (condition_speed - relative_speed)
	_rapid_speed_slope = (condition_speed + relative_speed) / condition_speed

	if relative_speed < 0:
		preferred_speed_getter = _get_gradual_preferred_speed
	else:
		preferred_speed_getter = _get_rapid_preferred_speed

	_inverted_max_speed = 1.0 / max_speed
	_rest_distance = max_following_distance - min_following_distance


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


func get_preferred_distance(speed_rate: float) -> float:
	return _rest_distance * speed_rate + min_following_distance


func _enter(lane: SimulatorLaneData, step: int):
	assert(len(pos_history) - 1 == step - spawn_step + 1)
	lane_history[step - spawn_step + 1] = lane.id
	lane.vehicles.append(self)


func _get_gradual_preferred_speed(speed_limit: float) -> float:
	var unbound_speed = maxf(speed_limit + relative_speed, _gradual_speed_slope * speed_limit)
	return minf(unbound_speed, max_speed)


func _get_rapid_preferred_speed(speed_limit: float) -> float:
	var unbound_speed = minf(speed_limit + relative_speed, _rapid_speed_slope * speed_limit)
	return minf(unbound_speed, max_speed)
