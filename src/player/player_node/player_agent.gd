class_name PlayerAgent
extends PlayerAnimatable

const DEAD_WEIGHT = 100

var _spawn_step: int
var _die_step: int

var _trail = Curve2D.new()
var _offsets: PackedFloat32Array

var _inactive_color: Color


func _init(agent: AgentData):
	super(AgentData.to_dict(agent))

	_spawn_step = agent.spawn_step
	_die_step = agent.die_step

	_offsets.resize(len(agent.pos_history))


func _after_init():
	if _die_step < 0:
		_die_step = player_global.simulation.parameter.max_step + 1
		_offsets.append(_offsets[-1])
	else:
		var point2 = _trail.get_point_position(_trail.point_count - 2)
		var point1 = _trail.get_point_position(_trail.point_count - 1)
		var point0 = point2.lerp(point1, DEAD_WEIGHT)
		_trail.add_point(point0)


func _process(_delta):
	if player_global.prev_step < _spawn_step or _die_step < player_global.next_step:
		visible = false
		return

	visible = true

	var prev_index = player_global.prev_step - _spawn_step
	var next_index = player_global.next_step - _spawn_step

	var prev_offset = _offsets[prev_index]
	var next_offset = _offsets[next_index]
	var offset = lerpf(prev_offset, next_offset, player_global.step_frac)
	transform = _trail.sample_baked_with_rotation(offset)


func _get_color():
	if selecting:
		return setting.selecting_color
	elif selected:
		return setting.selected_color
	else:
		return _inactive_color
