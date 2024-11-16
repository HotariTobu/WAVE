extends EditorPropertyPanelContent

var lane_vertex_sources: Array[EditorBindingSource]:
	get:
		return lane_vertex_sources
	set(next):
		var prev = lane_vertex_sources

		if not prev.is_empty():
			_unbind_cells(prev)

		if not next.is_empty():
			_bind_cells(next)

		lane_vertex_sources = next

var _editor_global = editor_global

@onready var _pos_panel: Vector2Panel = $PosPanel
@onready var _x_box: NumericBox = _pos_panel.get_x_box()
@onready var _y_box: NumericBox = _pos_panel.get_y_box()


func _ready():
	_x_box.value_changed.connect(_on_x_box_value_changed)
	_y_box.value_changed.connect(_on_y_box_value_changed)


func get_target_type():
	return EditorLaneVertex


func activate():
	super()
	var converter = ItemsToSourcesConverter.new(EditorLaneVertex)
	_editor_global.data.bind(&"selected_items").using(converter).to(self, &"lane_vertex_sources")


func deactivate():
	super()
	_editor_global.data.unbind(&"selected_items").from(self, &"lane_vertex_sources")
	lane_vertex_sources = []


func _bind_cells(sources: Array[EditorBindingSource]):
	var first_source = sources.front() as EditorBindingSource

	var x_of = func(pos: Vector2): return pos.x
	var y_of = func(pos: Vector2): return pos.y

	var unity_converter_x = UnifyConverter.new(func(): return first_source.pos.x)
	var unity_converter_y = UnifyConverter.new(func(): return first_source.pos.y)

	for source in sources:
		source.bind(&"pos").using(x_of).using(unity_converter_x).to(_x_box, &"value")
		source.bind(&"pos").using(y_of).using(unity_converter_y).to(_y_box, &"value")


func _unbind_cells(sources: Array[EditorBindingSource]):
	for source in sources:
		source.unbind(&"pos").from(_x_box, &"value")
		source.unbind(&"pos").from(_y_box, &"value")


func _on_x_box_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change lane vertex pos x")

	for source in lane_vertex_sources:
		var prev = source.pos as Vector2
		var next = Vector2(new_value, prev.y)

		_editor_global.undo_redo.add_do_property(source, &"pos", next)
		_editor_global.undo_redo.add_undo_property(source, &"pos", prev)

	_editor_global.undo_redo.commit_action()


func _on_y_box_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change lane vertex pos y")

	for source in lane_vertex_sources:
		var prev = source.pos as Vector2
		var next = Vector2(prev.x, new_value)

		_editor_global.undo_redo.add_do_property(source, &"pos", next)
		_editor_global.undo_redo.add_undo_property(source, &"pos", prev)

	_editor_global.undo_redo.commit_action()
