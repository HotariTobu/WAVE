class_name EditorStoplightCore
extends EditorSelectable

var stoplight: EditorStoplightData:
	get:
		return _stoplight

var _editor_global = editor_global

var _stoplight: EditorStoplightData

func _init(data: EditorStoplightData):
	super(EditorPhysicsLayer.STOPLIGHT_CORE)
	name = data.id

	_stoplight = data

	var source = _editor_global.source_db.get_or_add(data, &'notified')
	source.bind(&"pos").to(self, &"position")

	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 0

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle_shape
	add_child(collision_shape)


func _draw():
	Spot.draw_to(self, setting.stoplight_color, setting.stoplight_radius, setting.stoplight_shape)
	
	var color: Color
	if selecting:
		color = setting.stoplight_selecting_color
	elif selected:
		color = setting.stoplight_selected_color
	else:
		return

	var radius = setting.selection_radius / zoom_factor
	draw_circle(Vector2.ZERO, radius, color)
