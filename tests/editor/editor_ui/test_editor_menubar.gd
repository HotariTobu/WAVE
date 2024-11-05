extends GutTest

const EditorMenuBar = preload("res://src/editor/editor_ui/editor_menubar.gd")
const EditorMenuBarScene = preload("res://src/editor/editor_ui/editor_menubar.tscn")

var _editor_global
var _menubar


func before_each():
	_editor_global = autofree(double(EditorGlobal).new())

	_menubar = autofree(EditorMenuBarScene.instantiate())
	_menubar._editor_global = _editor_global


class TestEditorMenuButton:
	extends GutTest

	const LABEL = "Menu Button Label"

	var _handler1
	var _handler2

	var _item1
	var _item2

	var _menu_button
	var _popup: PopupMenu
	var _sender

	func before_all():
		register_inner_classes(get_script())

	func before_each():
		_handler1 = double(Object).new()
		_handler2 = double(Object).new()

		_item1 = EditorMenuBar.EditorMenuItem.new("Item 1", _handler1.to_string)
		_item2 = EditorMenuBar.EditorMenuItem.new("Item 2", _handler2.to_string)

		_menu_button = EditorMenuBar.EditorMenuButton.new(LABEL, [_item1, _item2])
		add_child_autofree(_menu_button)
		_popup = _menu_button.get_popup()
		_sender = InputSender.new(_menu_button)

	func test_init():
		assert_eq(_menu_button.text, LABEL)
		assert_eq(_menu_button.items, [_item1, _item2])

	func test_action_call():
		_popup.id_pressed.emit(0)
		assert_call_count(_handler1, "to_string", 1)

		_popup.id_pressed.emit(1)
		assert_call_count(_handler2, "to_string", 1)


class TestEditorMenuItem:
	extends GutTest

	const LABEL = "Menu Item Label"
	const ACTION_NAME = &"action_name"

	func test_init_with_action_name():
		var menu_item = EditorMenuBar.EditorMenuItem.new(LABEL, _action, ACTION_NAME)

		assert_same(menu_item.label, LABEL)
		assert_same(menu_item.action, _action)

		assert_not_null(menu_item.shortcut)
		assert_ne(len(menu_item.shortcut.events), 0)
		assert_is(menu_item.shortcut.events[0], InputEventAction)
		assert_same(menu_item.shortcut.events[0].action, ACTION_NAME)

	func test_init_without_action_name():
		var menu_item = EditorMenuBar.EditorMenuItem.new(LABEL, _action)

		assert_same(menu_item.label, LABEL)
		assert_same(menu_item.action, _action)

		assert_not_null(menu_item.shortcut)
		assert_ne(len(menu_item.shortcut.events), 0)
		assert_is(menu_item.shortcut.events[0], InputEventAction)
		assert_eq(menu_item.shortcut.events[0].action, "")

	func _action():
		pass
