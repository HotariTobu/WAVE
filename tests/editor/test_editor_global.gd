extends GutTest

var _editor_global

var _tool1
var _tool2


func before_each():
	_editor_global = autofree(EditorGlobal.new())
	watch_signals(_editor_global)

	_tool1 = autofree(double(EditorTool).new())
	_tool2 = autofree(double(EditorTool).new())


# func test_tool():
# 	assert_not_null(_editor_global.data.tool)

# 	_editor_global.data.tool = _tool1
# 	assert_same(_editor_global.data.tool, _tool1)
# 	assert_call_count(_tool1, "activate", 1)

# 	_editor_global.data.tool = _tool2
# 	assert_same(_editor_global.data.tool, _tool2)
# 	assert_call_count(_tool1, "deactivate", 1)
# 	assert_call_count(_tool2, "activate", 1)


# func test_tools():
# 	assert_eq(_editor_global.data.tools, [])

# 	var tools: Array[EditorTool] = [_tool1, _tool2]
# 	_editor_global.data.tools = tools
# 	assert_same(_editor_global.data.tools, tools)

#func test_serialize():
	#_editor_global.lane_container = Node.new()
	#
	#var lane0 = EditorLane.new()
	#var curve0 = Curve2D.new()
	#curve0.add_point(Vector2.ZERO)
	#curve0.add_point(Vector2.ONE)
	#curve0.add_point(Vector2.LEFT)
	#lane0.curve = curve0
	#_editor_global.lane_container.add_child(lane0)
#
	#var lane1 = EditorLane.new()
	#var curve1 = Curve2D.new()
	#curve1.add_point(Vector2.RIGHT)
	#curve1.add_point(Vector2.UP)
	#curve1.add_point(Vector2.DOWN)
	#lane1.curve = curve1
	#_editor_global.lane_container.add_child(lane1)
#
	#var lane2 = EditorLane.new()
	#var curve2 = Curve2D.new()
	#curve2.add_point(-Vector2.ONE)
	#curve2.add_point(Vector2.ZERO)
	#curve2.add_point(Vector2.RIGHT)
	#lane2.curve = curve2
	#lane2.add_next_lane(lane1)
	#_editor_global.lane_container.add_child(lane2)
	#
	#var dict = _editor_global.to_dict()
	#
	#var restored_editor_global = autofree(EditorGlobal.new())
	#restored_editor_global.lane_container = Node.new()
	#restored_editor_global.from_dict(dict)
	#
	#assert_true(_eq(_editor_global, restored_editor_global))
	#
	#fail_test('otphan')

func _eq(a, b):
	var type = typeof(a)
	if type != typeof(b):
		return false

	if type != TYPE_OBJECT:
		if a!=b:
			breakpoint
		return a == b

	if a == null and b == null:
		return true

	var property_list = a.get_property_list()
	if property_list != b.get_property_list():
		return false

	var get_name = func(property: Dictionary):
		return property['name']

	var is_in = func(name: String):
		return name == name.to_lower() and not name.ends_with('.gd') and name in a and name in b and not (a is Node and name == 'name')

	var comp = func(name: String):
		return _eq(a[name], b[name])

	return property_list.map(get_name).filter(is_in).all(comp)

#class TestSelection:
	#extends GutTest
#
	#var _selection
#
	#var _item1
	#var _item2
#
	#func before_each():
		#_selection = autofree(EditorGlobal.Selection.new())
		#watch_signals(_selection)
#
		#_item1 = autofree(double(EditorSelectable).new(0))
		#_item2 = autofree(double(EditorSelectable).new(0))
#
	#func test_add():
		#_selection.add(_item1)
#
		#assert_true(_selection.has(_item1))
		#assert_true(_item1.selected)
		#assert_eq(_selection.get_items(), [_item1])
		#assert_signal_emitted_with_parameters(_selection, "item_added", [_item1])
		#assert_signal_emit_count(_selection, "item_added", 1)
		#assert_signal_emitted_with_parameters(_selection, "items_changed", [[_item1]])
		#assert_signal_emit_count(_selection, "items_changed", 1)
#
	#func test_add_all():
		#_selection.add_all([_item1, _item2] as Array[EditorSelectable])
#
		#assert_true(_selection.has(_item1))
		#assert_true(_selection.has(_item2))
		#assert_true(_item1.selected)
		#assert_true(_item2.selected)
		#assert_eq(_selection.get_items(), [_item1, _item2])
		#assert_signal_emitted_with_parameters(_selection, "item_added", [_item1], 0)
		#assert_signal_emitted_with_parameters(_selection, "item_added", [_item2], 1)
		#assert_signal_emit_count(_selection, "item_added", 2)
		#assert_signal_emitted_with_parameters(_selection, "items_changed", [[_item1, _item2]])
		#assert_signal_emit_count(_selection, "items_changed", 1)
#
	#func test_remove():
		#_selection.add(_item1)
		#_selection.remove(_item1)
#
		#assert_false(_selection.has(_item1))
		#assert_false(_item1.selected)
		#assert_eq(_selection.get_items(), [])
		#assert_signal_emitted_with_parameters(_selection, "item_removed", [_item1])
		#assert_signal_emit_count(_selection, "item_removed", 1)
		#assert_signal_emitted_with_parameters(_selection, "items_changed", [[_item1]], 0)
		#assert_signal_emitted_with_parameters(_selection, "items_changed", [[]], 1)
		#assert_signal_emit_count(_selection, "items_changed", 2)
#
	#func test_clear():
		#_selection.add(_item1)
		#_selection.add(_item2)
		#_selection.clear()
#
		#assert_false(_selection.has(_item1))
		#assert_false(_selection.has(_item2))
		#assert_false(_item1.selected)
		#assert_false(_item2.selected)
		#assert_eq(_selection.get_items(), [])
		#assert_signal_emitted_with_parameters(_selection, "item_removed", [_item1], 0)
		#assert_signal_emitted_with_parameters(_selection, "item_removed", [_item2], 1)
		#assert_signal_emit_count(_selection, "item_removed", 2)
		#assert_signal_emitted_with_parameters(_selection, "items_changed", [[_item1]], 0)
		#assert_signal_emitted_with_parameters(_selection, "items_changed", [[_item1, _item2]], 1)
		#assert_signal_emitted_with_parameters(_selection, "items_changed", [[]], 2)
		#assert_signal_emit_count(_selection, "items_changed", 3)
#
	#func test_has():
		#assert_false(_selection.has(_item1))
		#_selection.add(_item1)
		#assert_true(_selection.has(_item1))
