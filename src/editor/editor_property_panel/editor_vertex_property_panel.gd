extends EditorPropertyPanelContent

@onready var _pos_panel = $PosPanel
@onready var _x_box: NumericBox = _pos_panel.get_x_box()
@onready var _y_box: NumericBox = _pos_panel.get_y_box()


func _ready():
	_x_box.value_changed.connect(_on_x_box_value_changed)
	_y_box.value_changed.connect(_on_y_box_value_changed)


func get_target_content_type() -> GDScript:
	return VertexData


func _bind_cells(next_proxy: BindingSourceProxy):
	next_proxy.bind(&"pos").using(_x_of).to(_x_box, &"value")
	next_proxy.bind(&"pos").using(_y_of).to(_y_box, &"value")


func _unbind_cells(prev_proxy: BindingSourceProxy):
	prev_proxy.unbind(&"pos").from(_x_box, &"value")
	prev_proxy.unbind(&"pos").from(_y_box, &"value")


func _on_x_box_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change lane vertex pos x")

	for source in source_proxy.sources:
		var prev = source.pos as Vector2
		var next = Vector2(new_value, prev.y)

		_editor_global.undo_redo.add_do_property(source, &"pos", next)
		_editor_global.undo_redo.add_undo_property(source, &"pos", prev)

	_editor_global.undo_redo.commit_action()


func _on_y_box_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change lane vertex pos y")

	for source in source_proxy.sources:
		var prev = source.pos as Vector2
		var next = Vector2(prev.x, new_value)

		_editor_global.undo_redo.add_do_property(source, &"pos", next)
		_editor_global.undo_redo.add_undo_property(source, &"pos", prev)

	_editor_global.undo_redo.commit_action()


static func _x_of(pos: Vector2) -> float:
	return pos.x


static func _y_of(pos: Vector2) -> float:
	return pos.y
