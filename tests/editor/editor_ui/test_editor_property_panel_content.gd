extends GutTest

const PropertyPanelContent = preload("res://src/editor/editor_ui/editor_property_panel_content.gd")

var _root_viewport: Viewport

var _property_panel_content: GridContainer

func before_each():
	_root_viewport = add_child_autofree(SubViewport.new())
	_root_viewport.gui_embed_subwindows = true
	
	_property_panel_content = PropertyPanelContent.new()
	_root_viewport.add_child(_property_panel_content)
	
func test_init():
	assert_eq(_property_panel_content.columns, 2)
	assert_false(_property_panel_content.visible)
	
func test_activate():
	_property_panel_content.activate()
	assert_true(_property_panel_content.visible)
	
func test_deactivate():
	_property_panel_content.deactivate()
	assert_false(_property_panel_content.visible)
	
func test_child_size():
	var control = Control.new()
	_property_panel_content.add_child(control)
	
	_property_panel_content.activate()
	
	_property_panel_content.size.x = 50
	await wait_frames(1)
	var width = control.size.x
	
	_property_panel_content.size.x = 100
	await wait_frames(1)
	assert_lt(width, control.size.x)

func test_line_edit_submit():
	var line_edit = LineEdit.new()
	_property_panel_content.add_child(line_edit)
	
	_property_panel_content.activate()
	
	line_edit.grab_focus()
	assert_true(line_edit.has_focus())
	
	_key(KEY_ENTER)
	assert_false(line_edit.has_focus())
	
func _key(key: int):
	var press_event = InputEventKey.new()
	press_event.keycode = key
	press_event.pressed = true

	var release_event = InputEventKey.new()
	release_event.keycode = key
	release_event.pressed = false

	_root_viewport.push_input(press_event)
	_root_viewport.push_input(release_event)
