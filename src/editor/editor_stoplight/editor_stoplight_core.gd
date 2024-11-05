class_name EditorStoplightCore
extends EditorSelectable

var stoplight: EditorStoplight

func _init(_stoplight: EditorStoplight):
	super(EditorPhysicsLayer.STOPLIGHT_CORE)

	stoplight = _stoplight

	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 0

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle_shape
	add_child(collision_shape)

func _draw():
	var color: Color
	if selecting:
		color = setting.stoplight_selecting_color
	elif selected:
		color = setting.stoplight_selected_color
	else:
		return

	var radius = setting.selection_radius / zoom_factor
	draw_circle(Vector2.ZERO, radius, color)

func _to_string():
	return "EditorStoplightCore(Stoplight: %s)" % stoplight
