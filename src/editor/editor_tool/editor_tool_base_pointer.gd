extends EditorTool

var _editor_global = editor_global

var _pointer_area = PointerArea.new()

var _hovered_items: Array[EditorSelectable]


func _init():
	_pointer_area.monitoring = false
	_pointer_area.collision_mask = _get_mask()
	add_child(_pointer_area)


func _ready():
	set_process_unhandled_input(false)


func _process(_delta):
	_pointer_area.radius = setting.pointer_area_radius / _editor_global.camera.zoom_value


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		_pointer_area.position = get_local_mouse_position()


func activate() -> void:
	_pointer_area.monitoring = true
	_pointer_area.area_entered.connect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.connect(_on_pointer_area_area_exited)

	set_process_unhandled_input(true)


func deactivate() -> void:
	_pointer_area.monitoring = false
	_pointer_area.area_entered.disconnect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.disconnect(_on_pointer_area_area_exited)

	set_process_unhandled_input(false)

	_hovered_items.clear()


func _get_mask() -> int:
	return 0


func _on_pointer_area_area_entered(area):
	var item = area as EditorSelectable
	_hovered_items.append(item)


func _on_pointer_area_area_exited(area):
	var item = area as EditorSelectable
	_hovered_items.erase(item)


class PointerArea:
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
		add_child(collision_shape)
