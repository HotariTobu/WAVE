class_name PlayerVehicle
extends PlayerAnimatable

var _length: float

var _spawn_step: int
var _die_step: int

var _pos_history: PackedFloat32Array
var _lane_history: Dictionary

var _moved_steps: PackedInt32Array
var _last_moved_next_index: int = -1
var _last_next_lane_length: float = NAN
var _last_duplicated_curve: Curve2D = null


func _init(vehicle: VehicleData):
	super(VehicleData.to_dict(vehicle))

	_collision_points = [Vector2.ZERO, Vector2.LEFT * vehicle.length]

	_length = vehicle.length

	_spawn_step = vehicle.spawn_step
	_die_step = vehicle.die_step

	_pos_history = vehicle.pos_history
	_lane_history = vehicle.lane_history

	_moved_steps = vehicle.lane_history.keys()
	_moved_steps.sort()

	if _die_step < 0:
		_die_step = player_global.simulation.parameter.max_step + 1
		_pos_history = _pos_history.duplicate()
		_pos_history.append(_pos_history[-1])


func _process(_delta):
	if player_global.prev_step < _spawn_step or _die_step < player_global.next_step:
		visible = false
		return

	visible = true

	var prev_index = player_global.prev_step - _spawn_step
	var next_index = player_global.next_step - _spawn_step

	var prev_pos = _pos_history[prev_index]
	var next_pos = _pos_history[next_index]

	var moved_step_key = _moved_steps.bsearch(prev_index, false) - 1
	var moved_step = _moved_steps[moved_step_key]

	var lane_id = _lane_history[moved_step]
	var lane = player_global.content_db.player_data_of(lane_id) as PlayerLaneData
	var curve = lane.curve

	if _lane_history.has(next_index):
		if _last_moved_next_index != next_index:
			var next_lane_id = _lane_history[next_index]
			var next_lane = player_global.content_db.player_data_of(next_lane_id) as PlayerLaneData

			_last_moved_next_index = next_index
			_last_next_lane_length = next_lane.length
			_last_duplicated_curve = curve.duplicate()
			_last_duplicated_curve.add_point(next_lane.points[1])

		next_pos -= _last_next_lane_length
		curve = _last_duplicated_curve

	var offset = lane.length - lerpf(prev_pos, next_pos, player_global.step_frac)
	transform = curve.sample_baked_with_rotation(offset)


func _draw():
	var color: Color
	if selecting:
		color = setting.selecting_color
	elif selected:
		color = setting.selected_color
	else:
		color = setting.vehicle_color

	AgentHelper.draw_to(self, setting.vehicle_head_length, _length, color, setting.vehicle_width)
