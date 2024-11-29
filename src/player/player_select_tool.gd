extends Node2D

var _pointer_area = PointerArea.new()

var _hovered_items: Array[PlayerSelectable]
var _last_hovered_item: PlayerSelectable:
	get:
		return _last_hovered_item
	set(next):
		var prev = _last_hovered_item

		if prev != null:
			prev.selecting = false

		if next != null:
			next.selecting = true

		_last_hovered_item = next
var _selected_item: PlayerSelectable:
	get:
		return _selected_item
	set(next):
		var prev = _selected_item

		if prev != null:
			prev.selected = false

		if next != null:
			next.selected = true

		_selected_item = next

@onready var _camera = get_viewport().get_camera_2d() as PanZoomCamera


func _init():
	_pointer_area.area_entered.connect(_on_pointer_area_area_entered)
	_pointer_area.area_exited.connect(_on_pointer_area_area_exited)
	add_child(_pointer_area)


func _process(_delta):
	_pointer_area.radius = setting.pointer_area_radius / _camera.zoom_value


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		_pointer_area.position = get_local_mouse_position()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_replace_selection()


func _on_pointer_area_area_entered(area):
	_hovered_items.append(area)
	_last_hovered_item = area


func _on_pointer_area_area_exited(area):
	_hovered_items.erase(area)
	if _hovered_items.is_empty():
		_last_hovered_item = null
	else:
		_last_hovered_item = _hovered_items.back()


func _replace_selection():
	if _hovered_items.is_empty():
		player_global.source.property_dict = {}
		_selected_item = null
	else:
		var item = _hovered_items.back() as PlayerSelectable
		player_global.source.property_dict = item.get_property_dict()
		_selected_item = item
