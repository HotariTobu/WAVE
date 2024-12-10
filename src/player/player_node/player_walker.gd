class_name PlayerWalker
extends PlayerAnimatable

var _size: float

var _spawn_step: int
var _die_step: int

var _pos_history: PackedFloat32Array

var _moved_steps: PackedInt32Array
var _step_bridge_dict: Dictionary

var _last_moved_next_index: int = -1
var _last_next_bridge_length: float = NAN
var _last_duplicated_curve: Curve2D = null
var _last_base_offset: float = 0.0

var _forward: bool


func _init(walker: WalkerData):
	super(WalkerData.to_dict(walker))

	_collision_points = [Vector2.ZERO]

	_size = walker.radius * 2

	_spawn_step = walker.spawn_step
	_die_step = walker.die_step

	_pos_history = walker.pos_history

	_moved_steps = walker.bridge_history.keys()
	_moved_steps.sort()

	for step in walker.bridge_history:
		var bridge_id = walker.bridge_history[step]
		_step_bridge_dict[step] = player_global.content_db.player_data_of(bridge_id)

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

	var bridge = _step_bridge_dict[moved_step] as PlayerBridgeData
	var base_pos = bridge.length
	var curve = bridge.curve

	if _step_bridge_dict.has(next_index):
		if _last_moved_next_index != next_index:
			var next_bridge = _step_bridge_dict[next_index] as PlayerBridgeData

			_last_moved_next_index = next_index
			_last_next_bridge_length = next_bridge.length
			_last_duplicated_curve = curve.duplicate()

			if bridge.start_vertex_id == next_bridge.start_vertex_id:
				_last_base_offset = next_bridge.points[0].distance_to(next_bridge.points[1])
				_last_duplicated_curve.add_point(next_bridge.points[1], Vector2.ZERO, Vector2.ZERO, 0)
			if bridge.end_vertex_id == next_bridge.start_vertex_id:
				_last_duplicated_curve.add_point(next_bridge.points[1])
			if bridge.start_vertex_id == next_bridge.end_vertex_id:
				_last_duplicated_curve.add_point(next_bridge.points[-2], Vector2.ZERO, Vector2.ZERO, 0)
			if bridge.end_vertex_id == next_bridge.end_vertex_id:
				_last_duplicated_curve.add_point(next_bridge.points[-2])

		next_pos -= _last_next_bridge_length
		curve = _last_duplicated_curve

	var offset = base_pos - lerpf(prev_pos, next_pos, player_global.step_frac)
	transform = curve.sample_baked_with_rotation(offset)

	if prev_pos < next_pos:
		_forward = false
	elif prev_pos > next_pos:
		_forward = true


func _draw():
	var color: Color
	if selecting:
		color = setting.selecting_color
	elif selected:
		color = setting.selected_color
	else:
		color = setting.walker_color

	AgentHelper.draw_to(self, setting.walker_head_length, _size, color, _size)
