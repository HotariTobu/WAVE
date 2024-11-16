class_name EditorSelectable
extends Area2D

signal notified(property: StringName)

var selecting: bool = false:
	get:
		return selecting
	set(value):
		selecting = value
		notified.emit(&"selecting")
		_on_property_updated()

var selected: bool = false:
	get:
		return selected
	set(value):
		selected = value
		notified.emit(&"selected")
		_on_property_updated()

var zoom_factor: float:
	get:
		var viewport_scale = get_viewport_transform().get_scale()
		return max(viewport_scale.x, viewport_scale.y)


func _init(layer: int):
	monitoring = false
	collision_layer = layer
	collision_mask = 0
	input_pickable = false
	z_as_relative = false
	visibility_changed.connect(_on_visibility_changed)


func _ready():
	set_process(false)


func _process(_delta):
	queue_redraw()


func get_local_center() -> Vector2:
	return Vector2.ZERO


func _on_property_updated():
	_update_process()
	_update_z_index()


func _update_process():
	set_process(selecting or selected)
	queue_redraw()


func _update_z_index():
	if selecting:
		z_index = 2
	elif selected:
		z_index = 1
	else:
		z_index = 0


func _on_visibility_changed():
	monitorable = is_visible_in_tree()


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
