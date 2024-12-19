class_name SimulatorStoplightExtension
extends SimulatorVertexExtension

var split_exts: Array[SimulatorSplitExtension]

var _active_split_ext: SimulatorSplitExtension
var _helper: StoplightHelper


func _init(data: StoplightData):
	super(data)


func extend(ext_of: Callable) -> void:
	super(ext_of)

	_assign_ext_array(&"split_exts", &"split_ids", ext_of)

	if split_exts.is_empty():
		return

	_active_split_ext = split_exts.front()
	_helper = StoplightHelper.new(_data.offset, split_exts)


func update_is_blocking(time: float):
	_active_split_ext.is_blocking = false

	var cycle_pos = _helper.calc_cycle_pos(time)
	var split_index = _helper.calc_split_index(cycle_pos)

	_active_split_ext = split_exts[split_index]
	_active_split_ext.is_blocking = true
