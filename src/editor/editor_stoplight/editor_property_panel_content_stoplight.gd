extends EditorPropertyPanelContent

const PlusIcon = preload("res://assets/plus.svg")
const CrossIcon = preload("res://assets/cross.svg")

const DURATION_LABEL = "Duration %s"

var stoplight_sources: Array[EditorBindingSource]:
	get:
		return stoplight_sources
	set(next):
		var prev = stoplight_sources

		if not prev.is_empty():
			_unbind_cells(prev)

		if not next.is_empty():
			_bind_cells(next)

		stoplight_sources = next

var _editor_global = editor_global

var _split_cells: Array[Control] = []:
	get:
		return _split_cells
	set(new_split_cells):
		for cell in _split_cells:
			cell.queue_free()

		for cell in new_split_cells:
			add_child(cell)

		_split_cells = new_split_cells

@onready var _pos_panel = $PosPanel
@onready var _x_box: NumericBox = _pos_panel.get_x_box()
@onready var _y_box: NumericBox = _pos_panel.get_y_box()

@onready var _offset_box = $OffsetBox


func _ready():
	_x_box.value_changed.connect(_on_x_box_value_changed)
	_y_box.value_changed.connect(_on_y_box_value_changed)


func get_target_type():
	return EditorStoplightCore


func activate():
	super()
	var converter = ItemsToSourcesConverter.new(EditorStoplightCore)
	_editor_global.data.bind(&"selected_items").using(converter).to(self, &"stoplight_sources")


func deactivate():
	super()
	_editor_global.data.unbind(&"selected_items").from(self, &"stoplight_sources")
	stoplight_sources = []


func _bind_cells(sources: Array[EditorBindingSource]):
	var first_source = sources.front() as EditorBindingSource

	var x_of = func(pos: Vector2): return pos.x
	var y_of = func(pos: Vector2): return pos.y

	var unity_converter_x = UnifyConverter.new(func(): return first_source.pos.x)
	var unity_converter_y = UnifyConverter.new(func(): return first_source.pos.y)

	var unity_converter = UnifyConverter.from_property(first_source, &"offset")

	for source in sources:
		source.bind(&"pos").using(x_of).using(unity_converter_x).to(_x_box, &"value")
		source.bind(&"pos").using(y_of).using(unity_converter_y).to(_y_box, &"value")

		source.bind(&"offset").using(unity_converter).to(_offset_box, &"value")

	if len(sources) == 1:
		var split_cell_creator = SplitCellCreator.new(first_source)
		first_source.bind(&"split_ids").using(split_cell_creator).to(self, &"_split_cells")


func _unbind_cells(sources: Array[EditorBindingSource]):
	var first_source = sources.front() as EditorBindingSource

	for source in sources:
		source.unbind(&"pos").from(_x_box, &"value")
		source.unbind(&"pos").from(_y_box, &"value")

		source.unbind(&"offset").from(_offset_box, &"value")

	if len(sources) == 1:
		first_source.unbind(&"split_ids").from(self, &"_split_cells")
		_split_cells = []


func _on_x_box_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change stoplight pos x")

	for source in stoplight_sources:
		var prev = source.pos as Vector2
		var next = Vector2(new_value, prev.y)

		_editor_global.undo_redo.add_do_property(source, &"pos", next)
		_editor_global.undo_redo.add_undo_property(source, &"pos", prev)

	_editor_global.undo_redo.commit_action()


func _on_y_box_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change stoplight pos y")

	for source in stoplight_sources:
		var prev = source.pos as Vector2
		var next = Vector2(prev.x, new_value)

		_editor_global.undo_redo.add_do_property(source, &"pos", next)
		_editor_global.undo_redo.add_undo_property(source, &"pos", prev)

	_editor_global.undo_redo.commit_action()


func _on_offset_box_value_changed(new_value: float):
	_editor_global.undo_redo.create_action("Change stoplight offset")

	for source in stoplight_sources:
		_editor_global.undo_redo.add_do_property(source, &"offset", new_value)
		_editor_global.undo_redo.add_undo_property(source, &"offset", source.offset)

	_editor_global.undo_redo.commit_action()


class SplitCellCreator:
	extends BindingConverter

	var _editor_global = editor_global

	var _stoplight_source: EditorBindingSource

	var _label_count: int

	func _init(stoplight_source: EditorBindingSource):
		_stoplight_source = stoplight_source

	func source_to_target(source_value: Variant) -> Variant:
		return _create_split_cells(source_value)

	func _create_split_cells(split_ids: Array[StringName]) -> Array[Control]:
		var split_cells: Array[Control] = []

		_label_count = 0

		for split_id in split_ids:
			var split = _editor_global.split_db.get_of(split_id)
			split_cells += _create_split_cell(split)

		var add_split_button = IconButton.new(PlusIcon)
		add_split_button.size_flags_horizontal = Control.SIZE_SHRINK_END
		add_split_button.pressed.connect(_on_add_split_button_pressed)
		split_cells += [Control.new(), add_split_button]

		return split_cells

	func _create_split_cell(split: SplitData) -> Array[Control]:
		var split_source = _editor_global.source_db.get_or_add(split)
		var stoplight_sector_node = _editor_global.get_content_node(split.id) as EditorStoplightSector

		_label_count += 1

		var duration_label = Label.new()
		duration_label.text = DURATION_LABEL % _label_count
		duration_label.mouse_filter = Control.MOUSE_FILTER_PASS
		_connect_hover_signals_for_selecting(duration_label, stoplight_sector_node)

		var duration_box = DurationBox.new()
		split_source.bind(&"duration").to(duration_box, &"value")
		_connect_hover_signals_for_selecting(duration_box, stoplight_sector_node)
		duration_box.value_changed.connect(_on_duration_box_value_changed.bind(split_source))

		var remove_split_button = IconButton.new(CrossIcon)
		remove_split_button.size_flags_horizontal |= SIZE_NO_EXPAND
		_connect_hover_signals_for_selecting(remove_split_button, stoplight_sector_node)
		remove_split_button.pressed.connect(_on_remove_split_button_pressed.bind(split))

		var h_box = HBoxContainer.new()
		h_box.add_child(duration_box)
		h_box.add_child(remove_split_button)

		return [duration_label, h_box] as Array[Control]

	func _on_duration_box_value_changed(new_value: float, split_source: EditorBindingSource):
		_editor_global.undo_redo.create_action("Change stoplight split duration")
		_editor_global.undo_redo.add_do_property(split_source, &"duration", new_value)
		_editor_global.undo_redo.add_undo_property(split_source, &"duration", split_source.duration)
		_editor_global.undo_redo.commit_action()

	func _on_add_split_button_pressed():
		var split = SplitData.new()
		split.duration = setting.default_split_duration

		var prev = _stoplight_source.split_ids as Array
		var next = prev.duplicate()
		next.append(split.id)
		next.make_read_only()

		_editor_global.undo_redo.create_action("Add stoplight split")

		_editor_global.undo_redo.add_do_method(_editor_global.split_db.add.bind(split))
		_editor_global.undo_redo.add_do_reference(split)
		_editor_global.undo_redo.add_undo_method(_editor_global.split_db.remove.bind(split))

		_editor_global.undo_redo.add_do_property(_stoplight_source, &"split_ids", next)
		_editor_global.undo_redo.add_undo_property(_stoplight_source, &"split_ids", prev)

		_editor_global.undo_redo.commit_action()

	func _on_remove_split_button_pressed(split: SplitData):
		var prev = _stoplight_source.split_ids as Array
		var next = prev.duplicate()
		next.erase(split.id)
		next.make_read_only()

		_editor_global.undo_redo.create_action("Remove stoplight split")

		_editor_global.undo_redo.add_do_method(_editor_global.split_db.remove.bind(split))
		_editor_global.undo_redo.add_undo_method(_editor_global.split_db.add.bind(split))
		_editor_global.undo_redo.add_undo_reference(split)

		_editor_global.undo_redo.add_do_property(_stoplight_source, &"split_ids", next)
		_editor_global.undo_redo.add_undo_property(_stoplight_source, &"split_ids", prev)

		_editor_global.undo_redo.commit_action()

	func _connect_hover_signals_for_selecting(control: Control, selectable: EditorSelectable):
		control.mouse_entered.connect(func(): selectable.selecting = true)
		control.mouse_exited.connect(func(): selectable.selecting = false)


class DurationBox:
	extends NumericBox

	func _init():
		super()

		min_value = 0
		select_all_on_focus = true
