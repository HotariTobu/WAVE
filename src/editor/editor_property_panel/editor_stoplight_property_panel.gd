extends EditorPropertyPanelContent

const PlusIcon = preload("res://assets/plus.svg")
const CrossIcon = preload("res://assets/cross.svg")

const DURATION_LABEL = "Duration %s"

var _split_cells: Array[Control] = []:
	get:
		return _split_cells
	set(new_split_cells):
		for cell in _split_cells:
			cell.queue_free()

		for cell in new_split_cells:
			add_child(cell)

		_split_cells = new_split_cells

@onready var _offset_box = $OffsetBox


func get_target_content_type() -> GDScript:
	return StoplightData


func _bind_cells(next_proxy: BindingSourceProxy):
	next_proxy.bind(&"offset").to(_offset_box, &"value")

	var next_sources = next_proxy.sources
	if len(next_sources) == 1:
		var first_source = next_sources.front() as EditorBindingSource
		var split_cell_creator = SplitCellCreator.new(first_source)
		first_source.bind(&"split_ids").using(split_cell_creator).to(self, &"_split_cells")


func _unbind_cells(prev_proxy: BindingSourceProxy):
	prev_proxy.bind(&"offset").to(_offset_box, &"value")

	var prev_sources = prev_proxy.sources
	if len(prev_sources) == 1:
		var first_source = prev_sources.front() as EditorBindingSource
		first_source.unbind(&"split_ids").from(self, &"_split_cells")
		_split_cells = []


func _on_offset_box_value_changed(new_value: float):
	_editor_global.undo_redo.create_action("Change stoplight offset")

	for source in source_proxy.sources:
		_editor_global.undo_redo.add_do_property(source, &"offset", new_value)
		_editor_global.undo_redo.add_undo_property(source, &"offset", source.offset)

	_editor_global.undo_redo.commit_action()


class SplitCellCreator:
	extends BindingConverter

	var _editor_global = editor_global
	var _split_db = _editor_global.content_db.get_group(&"splits")

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
			var split = _split_db.data_of(split_id)
			split_cells += _create_split_cell(split)

		var add_split_button = IconButton.new(PlusIcon)
		add_split_button.size_flags_horizontal = Control.SIZE_SHRINK_END
		add_split_button.pressed.connect(_on_add_split_button_pressed)
		split_cells += [Control.new(), add_split_button]

		return split_cells

	func _create_split_cell(split: SplitData) -> Array[Control]:
		var split_source = _editor_global.source_db.get_or_add(split)
		var stoplight_sector_node = _editor_global.content_node_of(split.id) as EditorStoplightSector

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
		var split = SplitData.new_default()

		var prev = _stoplight_source.split_ids as Array
		var next = prev.duplicate()
		next.append(split.id)

		_editor_global.undo_redo.create_action("Add stoplight split")

		_editor_global.undo_redo.add_do_method(_split_db.add.bind(split))
		_editor_global.undo_redo.add_do_reference(split)
		_editor_global.undo_redo.add_undo_method(_split_db.remove.bind(split))

		_editor_global.undo_redo.add_do_property(_stoplight_source, &"split_ids", next)
		_editor_global.undo_redo.add_undo_property(_stoplight_source, &"split_ids", prev)

		_editor_global.undo_redo.commit_action()

	func _on_remove_split_button_pressed(split: SplitData):
		var prev = _stoplight_source.split_ids as Array
		var next = prev.duplicate()
		next.erase(split.id)

		_editor_global.undo_redo.create_action("Remove stoplight split")

		_editor_global.undo_redo.add_do_method(_split_db.remove.bind(split))
		_editor_global.undo_redo.add_undo_method(_split_db.add.bind(split))
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

		suffix = " s"
		min_value = 0
		select_all_on_focus = true
