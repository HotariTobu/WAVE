class_name PlayerVehicle
extends PlayerAgent


func _init(vehicle: VehicleData):
	super(vehicle)
	_collision_points = [Vector2.ZERO, Vector2.LEFT * vehicle.length]
	_transformer = Transformer.new()
	_mutator = Mutator.new()
	_helper = Helper.new(vehicle.length)


class Mutator:
	extends PlayerAgent.Mutator

	var _next_space_length: float

	func update(space: PlayerSpaceData, next_space: PlayerSpaceData) -> void:
		super(space, next_space)
		_duplicated_curve.add_point(next_space.points[1])
		_next_space_length = next_space.length


	func mutate(transformer: Transformer) -> void:
		super(transformer)
		transformer.next_pos -= _next_space_length


class Helper:
	extends PlayerAgent.Helper

	var _length: float


	func _init(length: float):
		_length = length


	func get_inactive_color() -> Color:
		return setting.vehicle_color


	func draw_to(canvas: CanvasItem, color: Color) -> void:
		AgentHelper.draw_to(canvas, setting.vehicle_width, setting.vehicle_head_length, _length, color)
