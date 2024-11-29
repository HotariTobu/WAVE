class_name Selectable
extends Area2D

var selecting: bool:
	get:
		return selecting
	set(value):
		selecting = value
		_on_selecting_changed()

var selected: bool:
	get:
		return selected
	set(value):
		selected = value
		_on_selected_changed()

var _collision_shapes = ObservableArray.new()
var _collision_points: PackedVector2Array:
	get:
		return _collision_points
	set(value):
		_collision_points = value
		_on_collision_points_changed()


func _init(layer: int):
	monitoring = false
	collision_layer = layer
	collision_mask = 0
	input_pickable = false

	_collision_shapes.value_inserted.connect(add_child.unbind(1))
	_collision_shapes.value_removed.connect(remove_child.unbind(1))

	visibility_changed.connect(_on_visibility_changed)


func _on_selecting_changed():
	queue_redraw()


func _on_selected_changed():
	queue_redraw()


func _on_collision_points_changed():
	_collision_shapes.clear()

	var point_count = len(_collision_points)
	if point_count == 0:
		return

	if point_count == 1:
		var circle = create_circle()
		circle.position = _collision_points[0]
		_collision_shapes.append(circle)
		return

	for index in range(point_count - 1):
		var segment = create_segment()
		segment.shape.a = _collision_points[index]
		segment.shape.b = _collision_points[index + 1]
		_collision_shapes.append(segment)


func _on_visibility_changed():
	monitorable = is_visible_in_tree()


static func create_circle() -> CollisionShape2D:
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
