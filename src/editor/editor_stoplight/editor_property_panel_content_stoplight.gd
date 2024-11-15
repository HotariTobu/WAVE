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

@onready var _offset_box = $OffsetBox

func get_target_type():
	return EditorStoplightCore


func activate():
	super()
	_editor_global.data.bind(&'selected_items').using(_get_stoplight_sources).to(self, &'stoplight_sources')

func deactivate():
	super()
	_editor_global.data.unbind(&'selected_items').from(self, &'stoplight_sources')
	stoplight_sources = []

func _get_stoplight_sources(items: Array[EditorSelectable]) -> Array[EditorBindingSource]:
	var sources: Array[EditorBindingSource] = []

	for item in items:
		var segments = item as EditorStoplightCore
		if segments == null:
			continue

		var stoplight = segments.stoplight
		var source = _editor_global.source_db.get_or_add(stoplight, &"notified")
		sources.append(source)

	return sources

func _bind_cells(sources: Array[EditorBindingSource]):
	var first_source = sources.front() as EditorBindingSource

	var unity_converter = UnifyConverter.new(first_source, &'offset')

	for source in sources:
		source.bind(&'offset').using(unity_converter).to(_offset_box, &'value')

	if len(sources) == 1:
		var split_cell_creator = SplitCellCreator.new(first_source)
		first_source.bind(&'split_ids').using(split_cell_creator).to(self, &'_split_cells')

func _unbind_cells(sources: Array[EditorBindingSource]):
	var first_source = sources.front() as EditorBindingSource

	for source in sources:
		source.unbind(&'offset').from(_offset_box, &'value')

	if len(sources) == 1:
		first_source.unbind(&'split_ids').from(self, &'_split_cells')
		_split_cells = []

func _on_offset_box_value_changed(new_value: float):
	_editor_global.undo_redo.create_action("Change stoplight offset")

	for source in stoplight_sources:
		_editor_global.undo_redo.add_do_property(source, &'offset', new_value)
		_editor_global.undo_redo.add_undo_property(source, &'offset', source.offset)

	_editor_global.undo_redo.commit_action()

class SplitCellCreator:
	extends BindingConverter
	
	var _editor_global = editor_global
	
	var _stoplight_source: EditorBindingSource
	
	func _init(stoplight_source: EditorBindingSource):
		_stoplight_source = stoplight_source
		
	func source_to_target(source_value: Variant) -> Variant:
		return _create_split_cells(source_value)

	func _create_split_cells(split_ids: Array[StringName]) -> Array[Control]:
		var split_cells: Array[Control] = []

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
		
		var duration_label = Label.new()
		duration_label.text = DURATION_LABEL % split_source.id.right(2)
		duration_label.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var duration_box = DurationBox.new()
		split_source.bind(&'duration').to(duration_box, &'value')
		duration_box.value_changed.connect(_on_duration_box_value_changed.bind(split_source))

		var remove_split_button = IconButton.new(CrossIcon)
		remove_split_button.set_deferred(&'size_flags_horizontal', Control.SIZE_FILL)
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
		
		_editor_global.undo_redo.create_action("Add stoplight split")
		
		_editor_global.undo_redo.add_do_method(_editor_global.split_db.add.bind(split))
		_editor_global.undo_redo.add_do_reference(split)
		_editor_global.undo_redo.add_undo_method(_editor_global.split_db.remove.bind(split))
		
		_editor_global.undo_redo.add_do_method(_stoplight_source.add_split.bind(split))
		_editor_global.undo_redo.add_undo_method(_stoplight_source.remove_split.bind(split))
		
		_editor_global.undo_redo.commit_action()

	func _on_remove_split_button_pressed(split: SplitData):
		_editor_global.undo_redo.create_action("Remove stoplight split")
		
		_editor_global.undo_redo.add_do_method(_editor_global.split_db.remove.bind(split))
		_editor_global.undo_redo.add_undo_method(_editor_global.split_db.add.bind(split))
		_editor_global.undo_redo.add_undo_reference(split)
		
		_editor_global.undo_redo.add_do_method(_stoplight_source.remove_split.bind(split))
		_editor_global.undo_redo.add_undo_method(_stoplight_source.add_split.bind(split))
		
		_editor_global.undo_redo.commit_action()
	
class DurationBox:
	extends NumericBox

	func _init():
		super()

		min_value = 0
		select_all_on_focus = true
