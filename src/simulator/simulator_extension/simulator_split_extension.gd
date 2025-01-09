class_name SimulatorSplitExtension
extends SimulatorContentExtension

var is_blocking: bool

var duration: float:
	get:
		return _data.duration

var _block_target_exts: Array[SimulatorContentExtension]


func _init(data: SplitData):
	super(data)


func extend(ext_of: Callable) -> void:
	super(ext_of)

	_assign_ext_array(&"_block_target_exts", &"block_target_ids", ext_of)

	for block_target_ext in _block_target_exts:
		block_target_ext.block_source_exts.append(self)
