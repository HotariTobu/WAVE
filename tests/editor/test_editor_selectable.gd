extends GutTest

const ERROR_INTERVAL = 10e-5

const CAMERA_ZOOMS = [0.1, 0.5, 1.0, 1.5, 2.0]
const LAYERS = [0, 1, 2, 3, 4]

var _selectable


func before_each():
	_selectable = autofree(EditorSelectable.new(0))


func test_zoom_factor(zoom = use_parameters(CAMERA_ZOOMS)):
	var viewport = SubViewport.new()
	add_child_autofree(viewport)

	var camera = Camera2D.new()
	camera.zoom = Vector2.ONE * zoom
	viewport.add_child(camera)

	viewport.add_child(_selectable)

	assert_almost_eq(_selectable.zoom_factor, zoom, ERROR_INTERVAL)


func test_init(layer = use_parameters(LAYERS)):
	var selectable = autofree(EditorSelectable.new(layer))
	assert_true(selectable.monitorable)
	assert_false(selectable.monitoring)
	assert_eq(selectable.collision_layer, layer)
	assert_eq(selectable.collision_mask, 0)
	assert_false(selectable.z_as_relative)

	assert_false(selectable.selecting)
	assert_false(selectable.selected)


func test_process():
	assert_false(_selectable.is_processing())

	_selectable.selecting = true
	_selectable.selected = false
	assert_true(_selectable.is_processing())

	_selectable.selecting = false
	_selectable.selected = true
	assert_true(_selectable.is_processing())

	_selectable.selecting = true
	_selectable.selected = true
	assert_true(_selectable.is_processing())

	_selectable.selecting = false
	_selectable.selected = false
	assert_false(_selectable.is_processing())


func test_z_index():
	var initial_z_index = _selectable.z_index

	_selectable.selecting = true
	_selectable.selected = false
	var selecting_z_index = _selectable.z_index

	_selectable.selecting = false
	_selectable.selected = true
	var selected_z_index = _selectable.z_index

	_selectable.selecting = true
	_selectable.selected = true
	assert_eq(_selectable.z_index, selecting_z_index)

	_selectable.selecting = false
	_selectable.selected = false
	assert_eq(_selectable.z_index, initial_z_index)

	assert_lt(initial_z_index, selected_z_index)
	assert_lt(selected_z_index, selecting_z_index)
