extends EditorPropertyPanelContent

@onready var _pos_panel = $PosPanel
@onready var _x_box: NumericBox = _pos_panel.get_x_box()
@onready var _y_box: NumericBox = _pos_panel.get_y_box()


func _ready():
	_x_box.value_changed.connect(_on_x_box_value_changed)
	_y_box.value_changed.connect(_on_y_box_value_changed)


func get_target_content_type() -> GDScript:
	return VertexData


func _bind_cells(next_sources: Array[EditorBindingSource]):
	var first_source = next_sources.front() as EditorBindingSource

	var x_of = func(pos: Vector2): return pos.x
	var y_of = func(pos: Vector2): return pos.y

	var unity_converter_x = UnifyConverter.new(func(): return first_source.pos.x)
	var unity_converter_y = UnifyConverter.new(func(): return first_source.pos.y)

	for source in next_sources:
		source.bind(&"pos").using(x_of).using(unity_converter_x).to(_x_box, &"value")
		source.bind(&"pos").using(y_of).using(unity_converter_y).to(_y_box, &"value")


func _unbind_cells(prev_sources: Array[EditorBindingSource]):
	for source in prev_sources:
		source.unbind(&"pos").from(_x_box, &"value")
		source.unbind(&"pos").from(_y_box, &"value")


func _on_x_box_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change lane vertex pos x")

	for source in sources:
		var prev = source.pos as Vector2
		var next = Vector2(new_value, prev.y)

		_editor_global.undo_redo.add_do_property(source, &"pos", next)
		_editor_global.undo_redo.add_undo_property(source, &"pos", prev)

	_editor_global.undo_redo.commit_action()


func _on_y_box_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change lane vertex pos y")

	for source in sources:
		var prev = source.pos as Vector2
		var next = Vector2(prev.x, new_value)

		_editor_global.undo_redo.add_do_property(source, &"pos", next)
		_editor_global.undo_redo.add_undo_property(source, &"pos", prev)

	_editor_global.undo_redo.commit_action()
