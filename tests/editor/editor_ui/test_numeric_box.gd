extends GutTest

var _root_viewport: Viewport

var _numeric_box: NumericBox

func before_each():
	_root_viewport = add_child_autofree(SubViewport.new())
	_root_viewport.gui_embed_subwindows = true
	
	var container = Control.new()
	_root_viewport.add_child(container)
	
	_numeric_box = NumericBox.new()
	_numeric_box.prefix = 'pre'
	_numeric_box.suffix = 'suf'
	container.add_child(_numeric_box)
	watch_signals(_numeric_box)
	
	var control = Control.new()
	control.focus_mode = Control.FOCUS_ALL
	container.add_child(control)
	
func test_prefix_suffix():
	_numeric_box.grab_focus()
	
	assert_eq(_numeric_box.value, null)
	assert_eq(_numeric_box.text, '')
	
	_numeric_box.value = 0.0
	assert_eq(_numeric_box.text, '0')
	
	_key(KEY_TAB)
	assert_eq(_numeric_box.text, 'pre0suf')
	
	_numeric_box.prefix = 'p'
	_numeric_box.suffix = 's'
	assert_eq(_numeric_box.text, 'p0s')
	
	_numeric_box.value = null
	assert_eq(_numeric_box.text, '')

func test_min_value():
	_numeric_box.grab_focus()
	
	_numeric_box.min_value = 10.0
	assert_eq(_numeric_box.value, null)
	
	_numeric_box.value = 0.0
	
	_numeric_box.min_value = 50.0
	assert_eq(_numeric_box.value, 50.0)
	assert_signal_emitted_with_parameters(_numeric_box, 'value_changed', [50.0])
	
	_numeric_box.value = 100.0
	assert_eq(_numeric_box.value, 100.0)
	
	_numeric_box.value = 10.0
	assert_eq(_numeric_box.value, 50.0)
	
	_key(KEY_A | KEY_MASK_CMD_OR_CTRL)
	_push_unicode_input('200')
	assert_eq(_numeric_box.text, '200')
	assert_eq(_numeric_box.value, 50.0)
	
	_key(KEY_ENTER)
	assert_eq(_numeric_box.text, '200')
	assert_eq(_numeric_box.value, 200.0)
	assert_signal_emitted_with_parameters(_numeric_box, 'value_changed', [200.0])
	
	_key(KEY_A | KEY_MASK_CMD_OR_CTRL)
	_push_unicode_input('20')
	assert_eq(_numeric_box.text, '20')
	assert_eq(_numeric_box.value, 200.0)
	
	_key(KEY_ENTER)
	assert_eq(_numeric_box.text, '50')
	assert_eq(_numeric_box.value, 50.0)
	assert_signal_emitted_with_parameters(_numeric_box, 'value_changed', [50.0])
	
	assert_signal_emit_count(_numeric_box, 'value_changed', 3)

func test_max_value():
	_numeric_box.grab_focus()
	
	_numeric_box.max_value = -10.0
	assert_eq(_numeric_box.value, null)
	
	_numeric_box.value = 0.0
	
	_numeric_box.max_value = -50.0
	assert_eq(_numeric_box.value, -50.0)
	assert_signal_emitted_with_parameters(_numeric_box, 'value_changed', [-50.0])
	
	_numeric_box.value = -100.0
	assert_eq(_numeric_box.value, -100.0)
	
	_numeric_box.value = -10.0
	assert_eq(_numeric_box.value, -50.0)
	
	_key(KEY_A | KEY_MASK_CMD_OR_CTRL)
	_push_unicode_input('-200')
	assert_eq(_numeric_box.text, '-200')
	assert_eq(_numeric_box.value, -50.0)
	
	_key(KEY_ENTER)
	assert_eq(_numeric_box.text, '-200')
	assert_eq(_numeric_box.value, -200.0)
	assert_signal_emitted_with_parameters(_numeric_box, 'value_changed', [-200.0])

	_key(KEY_A | KEY_MASK_CMD_OR_CTRL)
	_push_unicode_input('-20')
	assert_eq(_numeric_box.text, '-20')
	assert_eq(_numeric_box.value, -200.0)
	
	_key(KEY_ENTER)
	assert_eq(_numeric_box.text, '-50')
	assert_eq(_numeric_box.value, -50.0)
	assert_signal_emitted_with_parameters(_numeric_box, 'value_changed', [-50.0])
	
	assert_signal_emit_count(_numeric_box, 'value_changed', 3)

func test_is_valid():
	_numeric_box.grab_focus()
	
	assert_false(_numeric_box.is_valid)
	
	_numeric_box.value = 0.0
	assert_true(_numeric_box.is_valid)
	
	_numeric_box.value = null
	assert_false(_numeric_box.is_valid)
	
	_key(KEY_A | KEY_MASK_CMD_OR_CTRL)
	_push_unicode_input('5')
	assert_eq(_numeric_box.text, '5')
	assert_eq(_numeric_box.value, null)
	assert_false(_numeric_box.is_valid)
	
	_key(KEY_ENTER)
	assert_eq(_numeric_box.text, '5')
	assert_eq(_numeric_box.value, 5.0)
	assert_true(_numeric_box.is_valid)
	assert_signal_emitted_with_parameters(_numeric_box, 'value_changed', [5.0])
	
	_key(KEY_A | KEY_MASK_CMD_OR_CTRL)
	_push_unicode_input('abc')
	assert_eq(_numeric_box.text, 'abc')
	assert_eq(_numeric_box.value, 5.0)
	assert_true(_numeric_box.is_valid)
	
	_key(KEY_ENTER)
	assert_eq(_numeric_box.text, 'abc')
	assert_eq(_numeric_box.value, 5.0)
	assert_false(_numeric_box.is_valid)
	
	_key(KEY_TAB)
	assert_eq(_numeric_box.text, 'pre5suf')
	assert_eq(_numeric_box.value, 5.0)
	assert_false(_numeric_box.is_valid)
	
	assert_signal_emit_count(_numeric_box, 'value_changed', 1)

func test_focus_exited():
	_numeric_box.grab_focus()
	_push_unicode_input('5')
	assert_eq(_numeric_box.text, '5')
	assert_eq(_numeric_box.value, null)
	_key(KEY_TAB)
	assert_eq(_numeric_box.value, 5.0)
	assert_signal_emitted_with_parameters(_numeric_box, 'value_changed', [5.0])
	
	_key(KEY_TAB | KEY_MASK_SHIFT)
	_key(KEY_A | KEY_MASK_CMD_OR_CTRL)
	_push_unicode_input('15')
	assert_eq(_numeric_box.text, '15')
	assert_eq(_numeric_box.value, 5.0)
	Input.action_press("ui_cancel")
	_numeric_box.release_focus()
	Input.action_release("ui_cancel")
	assert_eq(_numeric_box.value, 5.0)

	assert_signal_emit_count(_numeric_box, 'value_changed', 1)

func _push_unicode_input(text: String):
	for index in range(len(text)):
		var unicode = text.unicode_at(index)
		_unicode(unicode)

func _key(key: int):
	var keycode = key & KEY_CODE_MASK

	var alt_pressed = key & KEY_MASK_ALT != 0
	var command_or_control_autoremap = key & KEY_MASK_CMD_OR_CTRL != 0
	var ctrl_pressed = key & KEY_MASK_CTRL != 0
	var meta_pressed = key & KEY_MASK_META != 0
	var shift_pressed = key & KEY_MASK_SHIFT != 0

	var press_event = InputEventKey.new()
	press_event.keycode = keycode
	press_event.key_label = keycode
	press_event.physical_keycode = keycode
	press_event.pressed = true

	press_event.alt_pressed = alt_pressed
	press_event.ctrl_pressed = ctrl_pressed
	press_event.meta_pressed = meta_pressed
	press_event.command_or_control_autoremap = command_or_control_autoremap
	press_event.shift_pressed = shift_pressed

	var release_event = InputEventKey.new()
	release_event.keycode = keycode
	release_event.key_label = keycode
	release_event.physical_keycode = keycode
	release_event.pressed = false

	release_event.alt_pressed = alt_pressed
	release_event.ctrl_pressed = ctrl_pressed
	release_event.meta_pressed = meta_pressed
	release_event.command_or_control_autoremap = command_or_control_autoremap
	release_event.shift_pressed = shift_pressed

	_root_viewport.push_input(press_event)
	_root_viewport.push_input(release_event)

func _unicode(unicode: int):
	var press_event = InputEventKey.new()
	press_event.pressed = true
	press_event.unicode = unicode

	var release_event = InputEventKey.new()
	release_event.pressed = false
	release_event.unicode = unicode

	_root_viewport.push_input(press_event)
	_root_viewport.push_input(release_event)
