extends EditorPropertyPanelContent

const WEIGHT_LABEL = "Weight %s"

var _option_cells: Array[Control]:
	get:
		return _option_cells
	set(next):
		var prev = _option_cells

		for cell in prev:
			cell.queue_free()

		for cell in next:
			add_child(cell)

		_option_cells = next

@onready var _traffic_box = $TrafficBox
@onready var _speed_limit_box = $SpeedLimitBox


func get_target_content_type() -> GDScript:
	return LaneData


func _bind_cells(next_sources: Array[EditorBindingSource]):
	var first_source = next_sources.front() as EditorBindingSource

	var traffic_converter = UnifyConverter.from_property(first_source, &"traffic")
	var speed_limit_converter = UnifyConverter.from_property(first_source, &"speed_limit")

	for source in next_sources:
		source.bind(&"traffic").using(traffic_converter).to(_traffic_box, &"value")
		source.bind(&"speed_limit").using(speed_limit_converter).to(_speed_limit_box, &"value")

	if len(next_sources) == 1:
		var option_cell_creator = OptionCellCreator.new()
		first_source.bind(&"next_option_dict").using(option_cell_creator).to(self, &"_option_cells")


func _unbind_cells(prev_sources: Array[EditorBindingSource]):
	var first_source = prev_sources.front() as EditorBindingSource

	for source in prev_sources:
		source.unbind(&"traffic").from(_traffic_box, &"value")
		source.unbind(&"speed_limit").from(_speed_limit_box, &"value")

	if len(prev_sources) == 1:
		first_source.unbind(&"next_option_dict").from(self, &"_option_cells")
		_option_cells = []


func _on_traffic_box_value_changed(new_value):
	_editor_global.undo_redo.create_action("Change lane traffic")

	for source in sources:
		_editor_global.undo_redo.add_do_property(source, &"traffic", new_value)
		_editor_global.undo_redo.add_undo_property(source, &"traffic", source.traffic)

	_editor_global.undo_redo.commit_action()


func _on_speed_limit_box_value_changed(new_value: float):
	_editor_global.undo_redo.create_action("Change lane speed limit")

	for source in sources:
		_editor_global.undo_redo.add_do_property(source, &"speed_limit", new_value)
		_editor_global.undo_redo.add_undo_property(source, &"speed_limit", source.speed_limit)

	_editor_global.undo_redo.commit_action()


class OptionCellCreator:
	extends BindingConverter

	var _editor_global = editor_global

	var _label_count: int

	func source_to_target(source_value: Variant) -> Variant:
		return _create_option_cells(source_value)

	func _create_option_cells(option_dict: Dictionary) -> Array[Control]:
		var option_cells: Array[Control] = []

		_label_count = 0

		for lane_id in option_dict:
			var option = option_dict[lane_id]
			option_cells += _create_option_cell(option, lane_id)

		return option_cells

	func _create_option_cell(option: LaneData.OptionData, lane_id: StringName) -> Array[Control]:
		var option_source = _editor_global.source_db.get_or_add(option)
		var lane_segments_node = _editor_global.content_node_of(lane_id) as EditorLaneSegments

		_label_count += 1

		var weight_label = Label.new()
		weight_label.text = WEIGHT_LABEL % _label_count
		weight_label.mouse_filter = Control.MOUSE_FILTER_PASS
		_connect_hover_signals_for_selecting(weight_label, lane_segments_node)

		var weight_box = WeightBox.new()
		option_source.bind(&"weight").to(weight_box, &"value")
		_connect_hover_signals_for_selecting(weight_box, lane_segments_node)
		weight_box.value_changed.connect(_on_weight_box_value_changed.bind(option_source))

		return [weight_label, weight_box] as Array[Control]

	func _on_weight_box_value_changed(new_value: float, option_source: EditorBindingSource):
		_editor_global.undo_redo.create_action("Change lane option weight")
		_editor_global.undo_redo.add_do_property(option_source, &"weight", new_value)
		_editor_global.undo_redo.add_undo_property(option_source, &"weight", option_source.weight)
		_editor_global.undo_redo.commit_action()

	func _connect_hover_signals_for_selecting(control: Control, selectable: EditorSelectable):
		control.mouse_entered.connect(func(): selectable.selecting = true)
		control.mouse_exited.connect(func(): selectable.selecting = false)


class WeightBox:
	extends NumericBox

	func _init():
		super()

		min_value = 0
		select_all_on_focus = true
