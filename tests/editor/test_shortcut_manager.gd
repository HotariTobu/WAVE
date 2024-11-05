extends GutTest

var _shortcut_manager
var _sender


func before_each():
	_shortcut_manager = ShortcutManager.new()
	watch_signals(_shortcut_manager)
	add_child_autofree(_shortcut_manager)
	_sender = InputSender.new(_shortcut_manager)

	_shortcut_manager.add_shortcut(_create_shortcut(KEY_A), 0)
	_shortcut_manager.add_shortcut(_create_shortcut(KEY_A), 1)
	_shortcut_manager.add_shortcut(_create_shortcut(KEY_A), 2)
	_shortcut_manager.add_shortcut(_create_shortcut(KEY_B), 3)
	_shortcut_manager.add_shortcut(_create_shortcut(KEY_B), 4)
	_shortcut_manager.add_shortcut(_create_shortcut(KEY_B), 5)


func test_shortcut_input():
	_sender.key_down(KEY_A)
	_sender.key_up(KEY_A)
	assert_signal_emitted(_shortcut_manager, "handled", [[0, 1, 2]])

	_sender.key_down(KEY_B)
	_sender.key_up(KEY_B)
	assert_signal_emitted(_shortcut_manager, "handled", [[3, 4, 5]])

	assert_signal_emit_count(_shortcut_manager, "handled", 2)


func test_clear_shortcuts():
	_shortcut_manager.clear_shortcuts()

	_sender.key_down(KEY_A)
	_sender.key_up(KEY_A)

	_sender.key_down(KEY_B)
	_sender.key_up(KEY_B)

	assert_signal_emit_count(_shortcut_manager, "handled", 0)


func _create_shortcut(key: Key):
	var shortcut_event = InputEventKey.new()
	shortcut_event.keycode = key

	var shortcut = Shortcut.new()
	shortcut.events.append(shortcut_event)

	return shortcut

# input_sender.gd

#if(r.has_method(&"_shortcut_input")):
#r._shortcut_input(event)
