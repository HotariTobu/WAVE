extends EditorPropertyPanelContent

const PlusIcon = preload("res://assets/plus.svg")
const CrossIcon = preload("res://assets/cross.svg")

const DURATION_LABEL = "Duration %s"

var stoplights: Array[BindingSource]:
	get:
		return stoplights
	set(next):
		var prev = stoplights

		if not prev.is_empty():
			_unbind_cells(prev)

		if not next.is_empty():
			_bind_cells(next)

		stoplights = next

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

@onready var _stoplight_selector = StoplightSelector.new(_editor_global.source_db)
@onready var _offset_box = $OffsetBox

func get_target_type():
	return EditorStoplightCore


func activate():
	super()
	_editor_global.data.bind('selected_items').using(_stoplight_selector).to(self, 'stoplights')

func deactivate():
	super()
	_editor_global.data.unbind('selected_items').from(self, 'stoplights')
	stoplights = []

func _bind_cells(_stoplights: Array[BindingSource]):
	var first_stoplight = _stoplights.front() as BindingSource

	var unity_converter = UnifyConverter.new(first_stoplight, 'offset')

	for stoplight in _stoplights:
		stoplight.bind('offset').using(unity_converter).to(_offset_box, 'value')

	if len(_stoplights) == 1:
		var split_cell_creator = SplitCellCreator.new(first_stoplight, _editor_global.undo_redo)
		first_stoplight.bind('splits').using(split_cell_creator).to(self, '_split_cells')

func _unbind_cells(_stoplights: Array[BindingSource]):
	var first_stoplight = _stoplights.front() as BindingSource

	for stoplight in _stoplights:
		stoplight.unbind('offset').from(_offset_box, 'value')

	if len(_stoplights) == 1:
		first_stoplight.unbind('splits').from(self, '_split_cells')
		_split_cells = []

func _on_offset_box_value_changed(new_value: float):
	_editor_global.undo_redo.create_action("Change stoplight offset")

	for stoplight in stoplights:
		_editor_global.undo_redo.add_do_property(stoplight, 'offset', new_value)
		_editor_global.undo_redo.add_undo_property(stoplight, 'offset', stoplight.offset)

	_editor_global.undo_redo.commit_action()

class StoplightSelector:
	extends BindingConverter

	var _source_db: BindingSourceDB

	func _init(source_db: BindingSourceDB):
		_source_db = source_db

	func source_to_target(source_value: Variant) -> Variant:
		var items = source_value as Array[EditorSelectable]
		var stoplights: Array[BindingSource] = []

		for item in items:
			var core = item as EditorStoplightCore
			if core == null:
				continue

			var stoplight = core.stoplight
			var source = _source_db.get_or_add(stoplight)
			stoplights.append(source)

		return stoplights

class SplitCellCreator:
	extends BindingConverter

	var _stoplight: BindingSource
	var _undo_redo: UndoRedo

	func _init(stoplight: BindingSource, undo_redo: UndoRedo):
		_stoplight = stoplight
		_undo_redo = undo_redo

	func source_to_target(source_value: Variant) -> Variant:
		var splits = source_value as Array
		var split_cells: Array[Control] = []

		for index in range(len(splits)):
			var split = splits[index]
			split_cells += _create_split_cell(index, split)

		var add_split_button = IconButton.new(PlusIcon)
		add_split_button.size_flags_horizontal = Control.SIZE_SHRINK_END
		add_split_button.pressed.connect(_on_add_split_button_pressed)
		split_cells += [Control.new(), add_split_button]

		return split_cells

	func _create_split_cell(index: int, split: BindingSource):
		var duration_label = Label.new()
		duration_label.text = DURATION_LABEL % (index + 1)
		duration_label.mouse_filter = Control.MOUSE_FILTER_PASS
		# duration_label.mouse_entered.connect(_on_duration_row_mouse_entered.bind(stoplight))
		# duration_label.mouse_exited.connect(_on_duration_row_mouse_exited.bind(stoplight))

		var duration_box = DurationBox.new()
		split.bind('duration').to(duration_box, 'value')
		# duration_box.mouse_entered.connect(_on_duration_row_mouse_entered.bind(stoplight))
		# duration_box.mouse_exited.connect(_on_duration_row_mouse_exited.bind(stoplight))
		duration_box.value_changed.connect(_on_duration_box_value_changed.bind(index))

		var remove_split_button = IconButton.new(CrossIcon)
		remove_split_button.set_deferred('size_flags_horizontal', Control.SIZE_FILL)
		remove_split_button.pressed.connect(_on_remove_split_button_pressed.bind(index))

		var h_box = HBoxContainer.new()
		h_box.add_child(duration_box)
		h_box.add_child(remove_split_button)

		return [duration_label, h_box] as Array[Control]

	func _on_duration_box_value_changed(new_value: float, index: int):
		var set_duration = func(value: float):
			var split = _stoplight.splits[index]
			split.duration = value

		var current_split = _stoplight.splits[index]
		var current_value = current_split.duration

		_undo_redo.create_action("Change stoplight split duration")
		_undo_redo.add_do_method(set_duration.bind(new_value))
		_undo_redo.add_undo_method(set_duration.bind(current_value))
		_undo_redo.commit_action()

	func _on_add_split_button_pressed():
		_undo_redo.create_action("Add stoplight split")
		_undo_redo.add_do_method(_stoplight.add_split)
		_undo_redo.add_undo_method(_stoplight.remove_split)
		_undo_redo.commit_action()

	func _on_remove_split_button_pressed(index: int):
		var current_split = _stoplight.splits[index]
		var dict = current_split.to_dict()
		var restore_split = func():
			_stoplight.add_split_at.call(index)
			var split = _stoplight.splits[index]
			var container = _stoplight.get_parent.call()
			split.from_dict(dict, container)
			split.emit_all()

		_undo_redo.create_action("Add stoplight split")
		_undo_redo.add_do_method(_stoplight.remove_split_at.bind(index))
		_undo_redo.add_undo_method(restore_split)
		_undo_redo.commit_action()

	# static func _on_duration_row_mouse_entered(stoplight: EditorStoplight):
	# 	stoplight.selecting = true


	# static func _on_duration_row_mouse_exited(stoplight: EditorStoplight):
	# 	stoplight.selecting = false

class DurationBox:
	extends NumericBox

	func _init():
		super()

		min_value = 0
		select_all_on_focus = true
