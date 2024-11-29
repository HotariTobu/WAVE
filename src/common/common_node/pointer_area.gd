class_name PointerArea
extends Area2D

var radius: float:
	get:
		return _circle_shape.radius
	set(value):
		_circle_shape.radius = value

var _circle_shape = CircleShape2D.new()


func _init():
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = _circle_shape

	collision_layer = 0
	monitorable = false
	input_pickable = false
	add_child(collision_shape)
