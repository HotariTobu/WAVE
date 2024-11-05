extends GutTest

const PropertyPanelScene = preload("res://src/editor/editor_ui/editor_property_panel.tscn")
const PropertyPanelContent = preload("res://src/editor/editor_ui/editor_property_panel_content.gd")

var _editor_global

var _property_panel

var _property_panel_content1
var _property_panel_content2

var _item1
var _item2

func before_each():
	_editor_global = autofree(double(EditorGlobal).new())
	
	_property_panel = PropertyPanelScene.instantiate()
	_property_panel._editor_global = _editor_global
	
	var content_container = _property_panel.content_container
	
	_property_panel_content1 = double(PropertyPanelContent).new()
	stub(_property_panel_content1, 'get_target_type').to_return(Item1)
	stub(_property_panel_content1, 'activate').to_call_super()
	stub(_property_panel_content1, 'deactivate').to_call_super()
	content_container.add_child(_property_panel_content1)
	
	_property_panel_content2 = double(PropertyPanelContent).new()
	stub(_property_panel_content2, 'get_target_type').to_return(Item2)
	stub(_property_panel_content2, 'activate').to_call_super()
	stub(_property_panel_content2, 'deactivate').to_call_super()
	content_container.add_child(_property_panel_content2)

	add_child_autofree(_property_panel)
	
	_item1 = autofree(Item1.new(0))
	_item2 = autofree(Item2.new(0))
	
func test_ready():
	assert_false(_property_panel_content1.visible)
	assert_false(_property_panel_content2.visible)

func test_select():
	_editor_global.selection.add(_item1)
	assert_true(_property_panel_content1.visible)
	assert_false(_property_panel_content2.visible)

	_editor_global.selection.add(_item2)
	assert_false(_property_panel_content1.visible)
	assert_false(_property_panel_content2.visible)

	_editor_global.selection.remove(_item1)
	assert_false(_property_panel_content1.visible)
	assert_true(_property_panel_content2.visible)

	_editor_global.selection.clear()
	assert_false(_property_panel_content1.visible)
	assert_false(_property_panel_content2.visible)

	var items = [
		autofree(Item1.new(0)),
		autofree(Item1.new(0)),
		autofree(Item1.new(0)),
	] as Array[EditorSelectable]
	_editor_global.selection.add_all(items)
	assert_true(_property_panel_content1.visible)
	assert_false(_property_panel_content2.visible)
	
	assert_call_count(_property_panel_content1, 'activate', 2)
	assert_call_count(_property_panel_content1, 'deactivate', 1)
	
	assert_call_count(_property_panel_content2, 'activate', 1)
	assert_call_count(_property_panel_content2, 'deactivate', 1)

class Item1:
	extends EditorSelectable
	
class Item2:
	extends EditorSelectable
