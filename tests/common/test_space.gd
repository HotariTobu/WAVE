extends GutTest

#const POINT_COUNT_AND_DRAW_COUNT = [
	#[0, 0], [1, 0], [2, 1], [3, 1]
#]
#
#var _space: Space

#func before_each():
	#_space = Space.new()
	#double(Node, DOUBLE_STRATEGY.INCLUDE_NATIVE)
	#Curve2D.new().free()
	#double(Curve2D, DOUBLE_STRATEGY.INCLUDE_NATIVE)
	##_space.curve = double(Curve2D, DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	#add_child_autofree(_space)
#
#func test_draw_condition(params = use_parameters(POINT_COUNT_AND_DRAW_COUNT)):
	#var point_count = params[0]
	#var draw_count = params[1]
	#
	#for _i in range(point_count):
		#_space.curve.add_point(Vector2.ZERO)
		#
	#stub(_space.curve, 'get_baked_points')
		#
	#_space.queue_redraw()
	#
	#assert_call_count(_space.curve, 'get_baked_points', draw_count)
