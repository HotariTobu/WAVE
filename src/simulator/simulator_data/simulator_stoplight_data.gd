class_name SimulatorStoplightData
extends SimulatorVertexData

var offset: float
var splits: Array[SimulatorSplitData]

var helper: StoplightHelper
var active_split: SimulatorSplitData


func assign(content: ContentData, data_of: Callable) -> void:
	super(content, data_of)
	var stoplight = content as StoplightData
	offset = stoplight.offset
	assign_array(&"splits", stoplight.split_ids, data_of)

	if splits.is_empty():
		return

	helper = StoplightHelper.new(offset, splits)
	active_split = splits[0]


func update_is_blocking(time: float):
	active_split.is_blocking = false

	var cycle_pos = helper.calc_cycle_pos(time)
	var split_index = helper.calc_split_index(cycle_pos)

	active_split = splits[split_index]
	active_split.is_blocking = true
