class_name PanZoomCamera
extends Camera2D

signal offset_changed(prev: Vector2, next: Vector2)
signal zoom_changed(prev: float, next: float)

const WHEEL_BUTTONS = [
	MOUSE_BUTTON_WHEEL_UP,
	MOUSE_BUTTON_WHEEL_DOWN,
	MOUSE_BUTTON_WHEEL_LEFT,
	MOUSE_BUTTON_WHEEL_RIGHT,
]

const ZOOM_IN_MAP = {
	MOUSE_BUTTON_WHEEL_UP: true,
	MOUSE_BUTTON_WHEEL_DOWN: false,
	MOUSE_BUTTON_WHEEL_LEFT: true,
	MOUSE_BUTTON_WHEEL_RIGHT: false,
}

const SHIFT_DIRECTION_MAP = {
	MOUSE_BUTTON_WHEEL_UP: Vector2.LEFT,
	MOUSE_BUTTON_WHEEL_DOWN: Vector2.RIGHT,
	MOUSE_BUTTON_WHEEL_LEFT: Vector2.UP,
	MOUSE_BUTTON_WHEEL_RIGHT: Vector2.DOWN,
}

const NORMAL_DIRECTION_MAP = {
	MOUSE_BUTTON_WHEEL_UP: Vector2.UP,
	MOUSE_BUTTON_WHEEL_DOWN: Vector2.DOWN,
	MOUSE_BUTTON_WHEEL_LEFT: Vector2.LEFT,
	MOUSE_BUTTON_WHEEL_RIGHT: Vector2.RIGHT,
}

@export var pan_button = MOUSE_BUTTON_MIDDLE
@export var invert_zoom = false

@export_range(0.01, 1) var min_zoom = 0.1
@export_range(1, 100) var max_zoom = 10

@export_range(1, 2) var zoom_factor = 1.1
@export_range(0, 1000) var pan_factor = 30

@export_range(0.1, 1) var magnify_zoom_factor = 0.1
@export_range(1, 10) var pan_gesture_factor = 3

var offset_value: Vector2:
	get:
		return offset
	set(next):
		var prev = offset
		if prev == next:
			return

		offset = next
		offset_changed.emit(prev, next)

var zoom_value: float:
	get:
		return (zoom.x + zoom.y) / 2
	set(value):
		var prev = zoom_value
		var next = clamp(value, min_zoom, max_zoom)
		if prev == next:
			return

		zoom = Vector2(next, next)
		zoom_changed.emit(prev, next)

var _start_mouse_pos = Vector2.INF
var _start_camera_offset = Vector2.INF


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if _start_mouse_pos != Vector2.INF:
			var drag_offset = event.position - _start_mouse_pos
			offset_value = _start_camera_offset - drag_offset / zoom_value

	elif event is InputEventMouseButton:
		if event.button_index == pan_button:
			if event.pressed:
				_start_mouse_pos = event.position
				_start_camera_offset = offset
			else:
				_start_mouse_pos = Vector2.INF

		elif event.button_index in WHEEL_BUTTONS:
			if event.pressed:
				_handle_mouse_wheel(event)

	elif event is InputEventPanGesture:
		offset_value += event.delta * pan_gesture_factor / zoom_value

	elif event is InputEventMagnifyGesture:
		_handle_magnify_gesture(event)


func _handle_mouse_wheel(event: InputEventMouseButton):
	var amount = event.factor if event.factor else 1.0

	if event.ctrl_pressed:
		var zoom_in = ZOOM_IN_MAP[event.button_index]
		_zoom(amount, zoom_in, event.position)
	elif event.shift_pressed:
		var direction = SHIFT_DIRECTION_MAP[event.button_index]
		_pan(amount, direction)
	else:
		var direction = NORMAL_DIRECTION_MAP[event.button_index]
		_pan(amount, direction)


func _handle_magnify_gesture(event: InputEventMagnifyGesture):
	var zoom_in = event.factor > 1.0
	var amount = event.factor if zoom_in else 1.0 / event.factor
	amount *= magnify_zoom_factor
	_zoom(amount, zoom_in, event.position)


func _zoom(amount: float, zoom_in: bool, mouse_pos: Vector2):
	var last_zoom_value = zoom_value
	var new_zoom_value = last_zoom_value

	var factor = zoom_factor ** amount

	if zoom_in != invert_zoom:
		new_zoom_value *= factor
	else:
		new_zoom_value /= factor

	zoom_value = new_zoom_value

	var center_pos = get_viewport_rect().size / 2
	var mouse_offset = mouse_pos - center_pos
	var zoom_offset = mouse_offset / zoom_value - mouse_offset / last_zoom_value
	offset_value -= zoom_offset


func _pan(amount: float, direction: Vector2):
	offset_value += pan_factor * amount * direction / zoom_value
