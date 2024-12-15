class_name PlayerAgent
extends PlayerAnimatable

var _spawn_step: int
var _die_step: int

var _pos_history: PackedFloat32Array

var _moved_indices: PackedInt32Array
var _moved_index_space_dict: Dictionary

var _last_moved_next_index: int = -1

var _transformer: Transformer
var _mutator: Mutator
var _helper: Helper


func _init(agent: AgentData):
	super(AgentData.to_dict(agent))

	_spawn_step = agent.spawn_step
	_die_step = agent.die_step

	_pos_history = agent.pos_history

	if _die_step < 0:
		_die_step = player_global.simulation.parameter.max_step + 1
		_pos_history = _pos_history.duplicate()
		_pos_history.append(_pos_history[-1])

	_moved_indices = agent.space_history.keys()
	_moved_indices.sort()

	for moved_index in agent.space_history:
		var lane_id = agent.space_history[moved_index]
		_moved_index_space_dict[moved_index] = player_global.content_db.player_data_of(lane_id)


func _process(_delta):
	if player_global.prev_step < _spawn_step or _die_step < player_global.next_step:
		visible = false
		return

	visible = true

	var prev_index = player_global.prev_step - _spawn_step
	var next_index = player_global.next_step - _spawn_step

	var moved_index_key = _moved_indices.bsearch(prev_index, false) - 1
	var moved_index = _moved_indices[moved_index_key]

	var space = _moved_index_space_dict[moved_index] as PlayerSpaceData

	_transformer.base_pos = space.length
	_transformer.prev_pos = _pos_history[prev_index]
	_transformer.next_pos = _pos_history[next_index]

	_transformer.curve = space.curve

	if _moved_index_space_dict.has(next_index):
		if _last_moved_next_index != next_index:
			_last_moved_next_index = next_index

			var next_space = _moved_index_space_dict[next_index] as PlayerSpaceData
			_mutator.update(space, next_space)

		_mutator.mutate(_transformer)

	transform = _transformer.get_transform()


func _draw():
	var color: Color
	if selecting:
		color = setting.selecting_color
	elif selected:
		color = setting.selected_color
	else:
		color = _helper.get_inactive_color()

	_helper.draw_to(self, color)


class Transformer:
	var base_pos: float
	var prev_pos: float
	var next_pos: float

	var curve: Curve2D


	func get_transform() -> Transform2D:
		var offset = base_pos - lerpf(prev_pos, next_pos, player_global.step_frac)
		var transform = curve.sample_baked_with_rotation(offset)
		return transform


class Mutator:
	var _duplicated_curve: Curve2D


	func update(space: PlayerSpaceData, _next_space: PlayerSpaceData) -> void:
		_duplicated_curve = space.curve.duplicate()


	func mutate(transform_context: Transformer) -> void:
		transform_context.curve = _duplicated_curve


class Helper:
	func get_inactive_color() -> Color:
		return Color()


	func draw_to(_canvas: CanvasItem, _color: Color) -> void:
		pass
