class_name PlayerWalker
extends PlayerAgent


func _init(walker: WalkerData):
	super(walker)
	_collision_points = [Vector2.ZERO]
	_transformer = Transformer.new()
	_mutator = Mutator.new()
	_helper = Helper.new(walker.radius * 2)


class Transformer:
	extends PlayerAgent.Transformer

	var _forward: bool


	func get_transform() -> Transform2D:
		var transform = super()

		if prev_pos < next_pos:
			_forward = false
		elif prev_pos > next_pos:
			_forward = true

		if _forward:
			return transform
		else:
			return transform.rotated_local(PI)


class Mutator:
	extends PlayerAgent.Mutator

	var _base_offset: float
	var _next_pos_func: Callable


	func update(space: PlayerSpaceData, next_space: PlayerSpaceData) -> void:
		super(space, next_space)

		if space.start_vertex_id == next_space.start_vertex_id:
			_duplicated_curve.add_point(next_space.points[1], Vector2.ZERO, Vector2.ZERO, 0)
			_base_offset = next_space.points[0].distance_to(next_space.points[1])
			_next_pos_func = func(pos: float): return next_space.length - pos + space.length

		elif space.end_vertex_id == next_space.start_vertex_id:
			_duplicated_curve.add_point(next_space.points[1])
			_base_offset = 0
			_next_pos_func = func(pos: float): return pos - next_space.length

		elif space.start_vertex_id == next_space.end_vertex_id:
			_duplicated_curve.add_point(next_space.points[-2], Vector2.ZERO, Vector2.ZERO, 0)
			_base_offset = next_space.points[-1].distance_to(next_space.points[-2])
			_next_pos_func = func(pos: float): return pos + space.length

		elif space.end_vertex_id == next_space.end_vertex_id:
			_duplicated_curve.add_point(next_space.points[-2])
			_base_offset = 0
			_next_pos_func = func(pos: float): return -pos


	func mutate(transformer: Transformer) -> void:
		super(transformer)
		transformer.base_pos += _base_offset
		transformer.next_pos = _next_pos_func.call(transformer.next_pos)


class Helper:
	extends PlayerAgent.Helper

	var _size: float


	func _init(size: float):
		_size = size


	func get_inactive_color() -> Color:
		return setting.walker_color


	func draw_to(canvas: CanvasItem, color: Color) -> void:
		AgentHelper.draw_to(canvas, _size, setting.walker_head_length, _size, color)
