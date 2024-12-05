extends EditorTool

var _pointer_area = PointerArea.new()

var _hovered_items: Array[EditorSelectable]

@onready var _camera = get_viewport().get_camera_2d() as PanZoomCamera


func _init():
	_pointer_area.monitoring = false
	_pointer_area.collision_mask = _get_mask()
	add_child(_pointer_area)


func _ready():
	set_process(false)
	set_process_unhandled_input(false)


func _process(_delta):
	_pointer_area.radius = setting.pointer_area_radius / _camera.zoom_value


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		_pointer_area.position = get_local_mouse_position()


func activate() -> void:
	_pointer_area.monitoring = true
	_pointer_area.area_entered.connect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.connect(_on_pointer_area_area_exited)

	set_process(true)
	set_process_unhandled_input(true)


func deactivate() -> void:
	_pointer_area.monitoring = false
	_pointer_area.area_entered.disconnect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.disconnect(_on_pointer_area_area_exited)

	set_process(false)
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
