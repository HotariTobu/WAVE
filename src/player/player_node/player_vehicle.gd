class_name PlayerVehicle
extends PlayerAnimatable

var _vehicle: VehicleData
var _moved_steps: PackedInt32Array
#var _curve_dict: Dictionary

func _init(vehicle: VehicleData):
	_vehicle = vehicle

	_moved_steps = vehicle.lane_history.keys()
	_moved_steps.sort()

	if vehicle.die_step < 0:
		vehicle.die_step = player_global.simulation.parameter.max_step


func _process(_delta):
	if player_global.prev_step < _vehicle.spawn_step or _vehicle.die_step < player_global.next_step:
		visible = false
		return

	visible = true

	var prev_index = player_global.prev_step - _vehicle.spawn_step
	var next_index = player_global.next_step - _vehicle.spawn_step

	var prev_pos = _vehicle.pos_history[prev_index]
	var next_pos = _vehicle.pos_history[next_index]

	var moved_step_key = _moved_steps.bsearch(prev_index, false) - 1
	var moved_step = _moved_steps[moved_step_key]

	var lane_id = _vehicle.lane_history[moved_step]
	var lane = player_global.content_db.player_data_of(lane_id) as PlayerLaneData
	var curve = lane.curve

	if _vehicle.lane_history.has(next_index):
		var next_lane_id = _vehicle.lane_history[next_index]
		var next_lane = player_global.content_db.player_data_of(next_lane_id) as PlayerLaneData
		next_pos -= next_lane.length
		curve = curve.duplicate()
		curve.add_point(next_lane.points[1])

	var offset = lane.length - lerpf(prev_pos, next_pos, player_global.step_frac)
	transform = curve.sample_baked_with_rotation(offset)


func _draw():
	Agent.draw_to(self, setting.vehicle_head_length, _vehicle.length, setting.vehicle_color, setting.vehicle_width)
