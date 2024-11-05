extends GutTest

const ERROR_INTERVAL = 10e-5
const ERROR_INTERVAL2 = Vector2(ERROR_INTERVAL, ERROR_INTERVAL)

const PAN_BUTTONS = [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]
const MIN_ZOOMS = [0.01, 0.1, 1.0]
const MAX_ZOOMS = [1.0, 10.0, 100.0]
const ZOOM_FACTORS = [1, 1.1, 1.5, 1.8, 2]
const PAN_FACTORS = [0, 10, 50, 100, 500, 1000]

var _viewport: SubViewport
var _subject: Node2D

var _camera: PanZoomCamera
var _sender

var _one_in_subject: Vector2:
	get:
		return _get_pos_in_subject(Vector2.ONE)

var _one_in_viewport: Vector2:
	get:
		return _get_pos_in_viewport(Vector2.ONE)


func before_all():
	_viewport = SubViewport.new()
	add_child(_viewport)
	_subject = Node2D.new()
	_viewport.add_child(_subject)


func after_all():
	_viewport.free()


func before_each():
	_camera = autofree(PanZoomCamera.new())
	_viewport.add_child(_camera)
	watch_signals(_camera)
	_sender = InputSender.new(_camera)


func test_pan_button(button = use_parameters(PAN_BUTTONS)):
	_camera.pan_button = button

	var initial_one = _one_in_subject
	_sender.mouse_button_down(button)
	_sender.mouse_relative_motion(Vector2.ONE)
	_sender.mouse_button_up(button)
	var displacement = _one_in_subject - initial_one

	assert_eq(displacement, -Vector2.ONE)
	assert_signal_emit_count(_camera, "zoom_changed", 0)
	assert_signal_emit_count(_camera, "offset_changed", 1)


func test_min_zoom(min_zoom = use_parameters(MIN_ZOOMS)):
	_camera.min_zoom = min_zoom

	var events = _get_wheel_event_pair_ctrl(MOUSE_BUTTON_WHEEL_DOWN)

	var last_zoom = _camera.zoom_value
	var event_count = 1

	while true:
		_sender.send_event(events[0])
		_sender.send_event(events[1])

		var zoom = _camera.zoom_value
		if last_zoom == zoom:
			break

		last_zoom = zoom
		event_count += 1

	var emit_count = get_signal_emit_count(_camera, "zoom_changed")

	assert_almost_eq(last_zoom, min_zoom, ERROR_INTERVAL)
	assert_almost_eq(emit_count, event_count, 1)


func test_max_zoom(max_zoom = use_parameters(MAX_ZOOMS)):
	_camera.max_zoom = max_zoom

	var events = _get_wheel_event_pair_ctrl(MOUSE_BUTTON_WHEEL_UP)

	var last_zoom = _camera.zoom_value
	var event_count = 1

	while true:
		_sender.send_event(events[0])
		_sender.send_event(events[1])

		var zoom = _camera.zoom_value
		if last_zoom == zoom:
			break

		last_zoom = zoom
		event_count += 1

	var emit_count = get_signal_emit_count(_camera, "zoom_changed")

	assert_almost_eq(last_zoom, max_zoom, ERROR_INTERVAL)
	assert_almost_eq(emit_count, event_count, 1)


func test_zoom_factor(zoom_factor = use_parameters(ZOOM_FACTORS)):
	var initial_factor = _camera.zoom_factor

	var events_up = _get_wheel_event_pair_ctrl(MOUSE_BUTTON_WHEEL_UP)
	var events_down = _get_wheel_event_pair_ctrl(MOUSE_BUTTON_WHEEL_DOWN)

	_camera.zoom = Vector2.ONE
	_sender.send_event(events_up[0])
	_sender.send_event(events_up[1])
	var default_up = _camera.zoom_value

	_camera.zoom = Vector2.ONE
	_sender.send_event(events_down[0])
	_sender.send_event(events_down[1])
	var default_down = _camera.zoom_value

	_camera.zoom_factor = zoom_factor

	_camera.zoom = Vector2.ONE
	_sender.send_event(events_up[0])
	_sender.send_event(events_up[1])
	var control_up = _camera.zoom_value

	_camera.zoom = Vector2.ONE
	_sender.send_event(events_down[0])
	_sender.send_event(events_down[1])
	var control_down = _camera.zoom_value

	var emit_count = 2 if zoom_factor == 1 else 4

	assert_eq(default_up < control_up, initial_factor < zoom_factor)
	assert_eq(default_down > control_down, initial_factor < zoom_factor)
	assert_signal_emit_count(_camera, "zoom_changed", emit_count)


func test_pan_factor(pan_factor = use_parameters(PAN_FACTORS)):
	_camera.pan_factor = pan_factor

	var initial_one

	var events = _get_wheel_event_pair(MOUSE_BUTTON_WHEEL_UP)

	_camera.zoom_value = 0.5
	_camera.offset = Vector2.ZERO
	initial_one = _one_in_viewport
	_sender.send_event(events[0])
	_sender.send_event(events[1])
	var displacement_05 = _one_in_viewport - initial_one

	_camera.zoom_value = 1.0
	_camera.offset = Vector2.ZERO
	initial_one = _one_in_viewport
	_sender.send_event(events[0])
	_sender.send_event(events[1])
	var displacement_10 = _one_in_viewport - initial_one

	_camera.zoom_value = 1.5
	_camera.offset = Vector2.ZERO
	initial_one = _one_in_viewport
	_sender.send_event(events[0])
	_sender.send_event(events[1])
	var displacement_15 = _one_in_viewport - initial_one

	var displacement = Vector2.DOWN * pan_factor
	var emit_count = 0 if pan_factor == 0 else 3

	assert_almost_eq(displacement_05, displacement, ERROR_INTERVAL2)
	assert_almost_eq(displacement_10, displacement, ERROR_INTERVAL2)
	assert_almost_eq(displacement_15, displacement, ERROR_INTERVAL2)
	assert_signal_emit_count(_camera, "zoom_changed", 3)
	assert_signal_emit_count(_camera, "offset_changed", emit_count)


func test_zoom_pan_by_drag():
	var initial_one

	_camera.zoom_value = 0.5
	_camera.offset = Vector2.ZERO
	initial_one = _one_in_viewport
	_sender.mouse_button_down(MOUSE_BUTTON_MIDDLE)
	_sender.mouse_relative_motion(Vector2.ONE)
	_sender.mouse_button_up(MOUSE_BUTTON_MIDDLE)
	var displacement_05 = _one_in_viewport - initial_one

	_camera.zoom_value = 1.0
	_camera.offset = Vector2.ZERO
	initial_one = _one_in_viewport
	_sender.mouse_button_down(MOUSE_BUTTON_MIDDLE)
	_sender.mouse_relative_motion(Vector2.ONE)
	_sender.mouse_button_up(MOUSE_BUTTON_MIDDLE)
	var displacement_10 = _one_in_viewport - initial_one

	_camera.zoom_value = 1.5
	_camera.offset = Vector2.ZERO
	initial_one = _one_in_viewport
	_sender.mouse_button_down(MOUSE_BUTTON_MIDDLE)
	_sender.mouse_relative_motion(Vector2.ONE)
	_sender.mouse_button_up(MOUSE_BUTTON_MIDDLE)
	var displacement_15 = _one_in_viewport - initial_one

	assert_almost_eq(displacement_05, Vector2.ONE, ERROR_INTERVAL2)
	assert_almost_eq(displacement_10, Vector2.ONE, ERROR_INTERVAL2)
	assert_almost_eq(displacement_15, Vector2.ONE, ERROR_INTERVAL2)
	assert_signal_emit_count(_camera, "zoom_changed", 3)
	assert_signal_emit_count(_camera, "offset_changed", 3)


func test_pinned_zoom():
	var initial_one

	var events_up = _get_wheel_event_pair_ctrl(MOUSE_BUTTON_WHEEL_UP)
	var events_down = _get_wheel_event_pair_ctrl(MOUSE_BUTTON_WHEEL_DOWN)

	events_up[0].position = Vector2.ONE
	events_up[1].position = Vector2.ONE
	events_down[0].position = Vector2.ONE
	events_down[1].position = Vector2.ONE

	_camera.zoom = Vector2.ONE
	_camera.offset = Vector2.ZERO
	initial_one = _one_in_subject
	_sender.send_event(events_up[0])
	_sender.send_event(events_up[1])
	var one_up = _get_pos_in_viewport(initial_one)

	_camera.zoom = Vector2.ONE
	_camera.offset = Vector2.ZERO
	initial_one = _one_in_subject
	_sender.send_event(events_down[0])
	_sender.send_event(events_down[1])
	var one_down = _get_pos_in_viewport(initial_one)

	assert_eq(one_up, Vector2.ONE)
	assert_eq(one_down, Vector2.ONE)
	assert_signal_emit_count(_camera, "zoom_changed", 2)
	assert_signal_emit_count(_camera, "offset_changed", 2)


func test_pan_normal_direction_by_wheel():
	var initial_one

	var events_up = _get_wheel_event_pair(MOUSE_BUTTON_WHEEL_UP)
	var events_down = _get_wheel_event_pair(MOUSE_BUTTON_WHEEL_DOWN)
	var events_left = _get_wheel_event_pair(MOUSE_BUTTON_WHEEL_LEFT)
	var events_right = _get_wheel_event_pair(MOUSE_BUTTON_WHEEL_RIGHT)

	initial_one = _one_in_subject
	_sender.send_event(events_up[0])
	_sender.send_event(events_up[1])
	var displacement_up = _one_in_subject - initial_one

	initial_one = _one_in_subject
	_sender.send_event(events_down[0])
	_sender.send_event(events_down[1])
	var displacement_down = _one_in_subject - initial_one

	initial_one = _one_in_subject
	_sender.send_event(events_left[0])
	_sender.send_event(events_left[1])
	var displacement_left = _one_in_subject - initial_one

	initial_one = _one_in_subject
	_sender.send_event(events_right[0])
	_sender.send_event(events_right[1])
	var displacement_right = _one_in_subject - initial_one

	assert_eq(displacement_up.normalized(), Vector2.UP)
	assert_eq(displacement_down.normalized(), Vector2.DOWN)
	assert_eq(displacement_left.normalized(), Vector2.LEFT)
	assert_eq(displacement_right.normalized(), Vector2.RIGHT)
	assert_signal_emit_count(_camera, "zoom_changed", 0)
	assert_signal_emit_count(_camera, "offset_changed", 4)


func test_pan_shift_direction_by_wheel():
	var initial_one

	var events_up = _get_wheel_event_pair_shift(MOUSE_BUTTON_WHEEL_UP)
	var events_down = _get_wheel_event_pair_shift(MOUSE_BUTTON_WHEEL_DOWN)
	var events_left = _get_wheel_event_pair_shift(MOUSE_BUTTON_WHEEL_LEFT)
	var events_right = _get_wheel_event_pair_shift(MOUSE_BUTTON_WHEEL_RIGHT)

	initial_one = _one_in_subject
	_sender.send_event(events_up[0])
	_sender.send_event(events_up[1])
	var displacement_up = _one_in_subject - initial_one

	initial_one = _one_in_subject
	_sender.send_event(events_down[0])
	_sender.send_event(events_down[1])
	var displacement_down = _one_in_subject - initial_one

	initial_one = _one_in_subject
	_sender.send_event(events_left[0])
	_sender.send_event(events_left[1])
	var displacement_left = _one_in_subject - initial_one

	initial_one = _one_in_subject
	_sender.send_event(events_right[0])
	_sender.send_event(events_right[1])
	var displacement_right = _one_in_subject - initial_one

	assert_eq(displacement_up.normalized(), Vector2.LEFT)
	assert_eq(displacement_down.normalized(), Vector2.RIGHT)
	assert_eq(displacement_left.normalized(), Vector2.UP)
	assert_eq(displacement_right.normalized(), Vector2.DOWN)
	assert_signal_emit_count(_camera, "zoom_changed", 0)
	assert_signal_emit_count(_camera, "offset_changed", 4)


func _get_pos_in_subject(pos_in_viewport: Vector2):
	return _subject.get_viewport_transform().inverse() * pos_in_viewport


func _get_pos_in_viewport(pos_in_subject: Vector2):
	return _subject.get_viewport_transform() * pos_in_subject


func _get_wheel_event_pair_ctrl(button: MouseButton):
	var events = _get_wheel_event_pair(button)
	events[0].ctrl_pressed = true
	events[1].ctrl_pressed = true
	return events


func _get_wheel_event_pair_shift(button: MouseButton):
	var events = _get_wheel_event_pair(button)
	events[0].shift_pressed = true
	events[1].shift_pressed = true
	return events


func _get_wheel_event_pair(button: MouseButton):
	var pressed_event = InputEventMouseButton.new()
	pressed_event.button_index = button
	pressed_event.factor = 1
	pressed_event.pressed = true

	var released_event = pressed_event.duplicate()
	released_event.pressed = false

	return [pressed_event, released_event]

# input_sender.gd

#func mouse_button_down(button: MouseButton, position=null, global_position=null):
#var event = _new_defaulted_mouse_button_event(position, global_position)
#event.pressed = true
#event.button_index = button
#_send_or_record_event(event)
#return self
#
#
#func mouse_button_up(button: MouseButton, position=null, global_position=null):
#var event = _new_defaulted_mouse_button_event(position, global_position)
#event.pressed = false
#event.button_index = button
#_send_or_record_event(event)
#return self
