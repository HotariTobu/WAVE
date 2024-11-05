extends GutTest

const EditorToolList = preload("res://src/editor/editor_ui/editor_tool_list.gd")

var _root_viewport: Viewport

var _editor_global

var _tool1
var _tool2
var _tool3

var _tool_list

func before_each():
	_root_viewport = add_child_autofree(SubViewport.new())
	_root_viewport.gui_embed_subwindows = true
	
	_editor_global = autofree(EditorGlobal.new())
	_tool1 = autofree(double(EditorTool).new())
	_tool1.shortcut = _create_shortcut(KEY_A)
	stub(_tool1, "get_id").to_return("id_1")
	stub(_tool1, "get_display_name").to_return("ID 1")

	_tool2 = autofree(double(EditorTool).new())
	_tool2.shortcut = _create_shortcut(KEY_B)
	stub(_tool2, "get_id").to_return("id_2")
	stub(_tool2, "get_display_name").to_return("ID 2")

	_tool3 = autofree(double(EditorTool).new())
	_tool3.shortcut = _create_shortcut(KEY_B)
	stub(_tool3, "get_id").to_return("id_3")
	stub(_tool3, "get_display_name").to_return("ID 3")
	
	var shortcut_manager = ShortcutManager.new()
	_root_viewport.add_child(shortcut_manager)

	_tool_list = EditorToolList.new()
	_tool_list.shortcut_manager = shortcut_manager
	_tool_list._editor_global = _editor_global
	_root_viewport.add_child(_tool_list)
	
	_editor_global.data.tools = [_tool1, _tool2, _tool3] as Array[EditorTool]
	_editor_global.data.tool = _tool1


func test_children():
	assert_eq(_tool_list.get_child_count(), 3)
	
	var tool_button1 = _tool_list.get_child(0) as EditorToolList.ToolButton
	var tool_button2 = _tool_list.get_child(1) as EditorToolList.ToolButton
	var tool_button3 = _tool_list.get_child(2) as EditorToolList.ToolButton
	
	assert_eq(tool_button1.tool_id, "id_1")
	assert_eq(tool_button2.tool_id, "id_2")
	assert_eq(tool_button3.tool_id, "id_3")
	
	_editor_global.data.tools = [] as Array[EditorTool]
	await wait_frames(1)
	assert_eq(_tool_list.get_child_count(), 0)

func test_toggle_button():
	var tool_button1 = _tool_list.get_child(0) as EditorToolList.ToolButton
	var tool_button2 = _tool_list.get_child(1) as EditorToolList.ToolButton
	var tool_button3 = _tool_list.get_child(2) as EditorToolList.ToolButton
	
	assert_true(tool_button1.button_pressed)
	assert_false(tool_button2.button_pressed)
	assert_false(tool_button3.button_pressed)
	
	_editor_global.data.tool = _tool2
	assert_false(tool_button1.button_pressed)
	assert_true(tool_button2.button_pressed)
	assert_false(tool_button3.button_pressed)
	
	_editor_global.data.tool = _tool3
	assert_false(tool_button1.button_pressed)
	assert_false(tool_button2.button_pressed)
	assert_true(tool_button3.button_pressed)
	
	_editor_global.data.tool = _tool1
	assert_true(tool_button1.button_pressed)
	assert_false(tool_button2.button_pressed)
	assert_false(tool_button3.button_pressed)

func test_shortcut():
	await wait_frames(1)
	
	_key(KEY_B)
	assert_eq(_editor_global.data.tool, _tool2)
	
	_key(KEY_B)
	assert_eq(_editor_global.data.tool, _tool3)
	
	_key(KEY_B)
	assert_eq(_editor_global.data.tool, _tool2)
	
	_key(KEY_A)
	assert_eq(_editor_global.data.tool, _tool1)

func test_button_press():
	var tool_button1 = _tool_list.get_child(0) as EditorToolList.ToolButton
	tool_button1.grab_focus()
	
	_key(KEY_TAB)
	_accept()
	assert_eq(_editor_global.data.tool, _tool2)
	
	_key(KEY_TAB)
	_accept()
	assert_eq(_editor_global.data.tool, _tool3)
	

func _create_shortcut(key: Key):
	var shortcut_event = InputEventKey.new()
	shortcut_event.keycode = key

	var shortcut = Shortcut.new()
	shortcut.events.append(shortcut_event)

	return shortcut

func _key(key: int):
	var press_event = InputEventKey.new()
	press_event.keycode = key
	press_event.pressed = true

	var release_event = InputEventKey.new()
	release_event.keycode = key
	release_event.pressed = false

	_root_viewport.push_input(press_event)
	_root_viewport.push_input(release_event)

func _accept():
	var press_event = InputEventAction.new()
	press_event.action = "ui_accept"
	press_event.pressed = true

	var release_event = InputEventAction.new()
	release_event.action = "ui_accept"
	release_event.pressed = false

	_root_viewport.push_input(press_event)
	_root_viewport.push_input(release_event)

class TestToolButton:
	extends GutTest

	var _tool1
	var _tool2

	var _button1
	var _button2

	func before_each():
		_tool1 = autofree(EditorTool.new())
		_tool2 = autofree(EditorTool.new())

		_button1 = autofree(EditorToolList.ToolButton.new(_tool1))
		_button2 = autofree(EditorToolList.ToolButton.new(_tool2))

		watch_signals(_button1)
		watch_signals(_button2)

	func test_init():
		assert_eq(_button1.tool_id, _tool1.get_id())
		assert_eq(_button1.text, _tool1.get_display_name())
		assert_same(_button1.button_group, _button2.button_group)
		assert_true(_button1.toggle_mode)

	func test_selected():
		_button1.toggled.emit(true)
		_button1.toggled.emit(false)

		assert_signal_emit_count(_button1, "selected", 1)
