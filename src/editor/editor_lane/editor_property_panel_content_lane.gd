extends EditorPropertyPanelContent

const WEIGHT_LABEL = "Weight %s"

var lanes: Array[BindingSource]:
	get:
		return lanes
	set(next):
		var prev = lanes

		if not prev.is_empty():
			_unbind_cells(prev)

		if not next.is_empty():
			_bind_cells(next)

		lanes = next

var _editor_global = editor_global

var _option_cells: Array[Control] = []:
	get:
		return _option_cells
	set(new_option_cells):
		for cell in _option_cells:
			cell.queue_free()

		for cell in new_option_cells:
			add_child(cell)

		_option_cells = new_option_cells

@onready var _lane_selector = LaneSelector.new(_editor_global.source_db)
@onready var _speed_limit_box = $SpeedLimitBox


func get_target_type():
	return EditorLaneSegments


func activate():
	super()
	_editor_global.data.bind('selected_items').using(_lane_selector).to(self, 'lanes')

func deactivate():
	super()
	_editor_global.data.unbind('selected_items').from(self, 'lanes')
	lanes = []

func _bind_cells(_lanes: Array[BindingSource]):
	var first_lane = _lanes.front() as BindingSource

	var unity_converter = UnifyConverter.new(first_lane, 'speed_limit')

	for lane in _lanes:
		lane.bind('speed_limit').using(unity_converter).to(_speed_limit_box, 'value')

	if len(_lanes) == 1:
		first_lane.bind('next_option_dict').using(_create_option_cells).to(self, '_option_cells')

func _unbind_cells(_lanes: Array[BindingSource]):
	var first_lane = _lanes.front() as BindingSource

	for lane in _lanes:
		lane.unbind('speed_limit').from(_speed_limit_box, 'value')

	if len(_lanes) == 1:
		first_lane.unbind('next_option_dict').from(self, '_option_cells')
		_option_cells = []

func _create_option_cells(option_dict: Dictionary):
	var option_cells: Array[Control] = []

	for lane in option_dict:
		var option = option_dict[lane]
		option_cells += _create_option_cell(lane, option)

	return option_cells

func _create_option_cell(lane: EditorLane, option: BindingSource):
	var index = lane.get_index()

	var weight_label = Label.new()
	weight_label.text = WEIGHT_LABEL % (index + 1)
	weight_label.mouse_filter = Control.MOUSE_FILTER_PASS
	weight_label.mouse_entered.connect(_on_weight_row_mouse_entered.bind(lane))
	weight_label.mouse_exited.connect(_on_weight_row_mouse_exited.bind(lane))

	var weight_box = WeightBox.new()
	option.bind('weight').to(weight_box, 'value')
	weight_box.mouse_entered.connect(_on_weight_row_mouse_entered.bind(lane))
	weight_box.mouse_exited.connect(_on_weight_row_mouse_exited.bind(lane))
	weight_box.value_changed.connect(_on_weight_box_value_changed.bind(lane))

	return [weight_label, weight_box] as Array[Control]

func _on_speed_limit_box_value_changed(new_value: float):
	_editor_global.undo_redo.create_action("Change lane speed limit")

	for lane in lanes:
		_editor_global.undo_redo.add_do_property(lane, 'speed_limit', new_value)
		_editor_global.undo_redo.add_undo_property(lane, 'speed_limit', lane.speed_limit)

	_editor_global.undo_redo.commit_action()

func _on_weight_box_value_changed(new_value: float, option_lane: EditorLane):
	var lane = lanes.front()
	var set_weight = func(value: float):
		var option = lane.next_option_dict[option_lane]
		option.weight = value

	var current_option = lane.next_option_dict[option_lane]
	var current_value = current_option.weight

	_editor_global.undo_redo.create_action("Change lane option weight")
	_editor_global.undo_redo.add_do_method(set_weight.bind(new_value))
	_editor_global.undo_redo.add_undo_method(set_weight.bind(current_value))
	_editor_global.undo_redo.commit_action()

static func _on_weight_row_mouse_entered(lane: EditorLane):
	lane.selecting = true


static func _on_weight_row_mouse_exited(lane: EditorLane):
	lane.selecting = false

class LaneSelector:
	extends BindingConverter

	var _source_db: BindingSourceDB

	func _init(source_db: BindingSourceDB):
		_source_db = source_db

	func source_to_target(source_value: Variant) -> Variant:
		var items = source_value as Array[EditorSelectable]
		var lanes: Array[BindingSource] = []

		for item in items:
			var segments = item as EditorLaneSegments
			if segments == null:
				continue

			var lane = segments.lane
			var source = _source_db.get_or_add(lane)
			lanes.append(source)

		return lanes

class WeightBox:
	extends NumericBox

	func _init():
		super()

		min_value = 0
		select_all_on_focus = true
