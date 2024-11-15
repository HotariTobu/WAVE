class_name EditorSelectable
extends Area2D

var selecting: bool = false:
	get:
		return selecting
	set(value):
		selecting = value
		_update_process()

var selected: bool = false:
	get:
		return selected
	set(value):
		selected = value
		_update_process()

var zoom_factor: float:
	get:
		var viewport_scale = get_viewport_transform().get_scale()
		return max(viewport_scale.x, viewport_scale.y)


func _init(layer: int):
	unique_name_in_owner = true
	monitoring = false
	collision_layer = layer
	collision_mask = 0
	z_as_relative = false


func _ready():
	owner = get_tree().root
	set_process(false)


func _process(_delta):
	queue_redraw()


func get_center() -> Vector2:
	return Vector2.ZERO


func _update_process():
	set_process(selecting or selected)
	queue_redraw()
	_update_z_index()


func _update_z_index():
	if selecting:
		z_index = 2
	elif selected:
		z_index = 1
	else:
		z_index = 0


static func create_point() -> CollisionShape2D:
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 0

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle_shape

	return collision_shape


static func create_segment() -> CollisionShape2D:
	var segment_shape = SegmentShape2D.new()

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = segment_shape

	return collision_shape
