class_name SimulatorSpaceExtension
extends SimulatorSegmentsExtension

var is_blocking: bool
var is_blocked: bool

var agent_exts: Array[SimulatorAgentExtension]

var block_target_exts: Array[SimulatorContentExtension]
var block_source_exts: Array[SimulatorContentExtension]


func _init(data: SpaceData):
	super(data)


func extend(ext_of: Callable) -> void:
	super(ext_of)

	_assign_ext_array(&"block_target_exts", &"block_target_ids", ext_of)

	for block_target_ext in block_target_exts:
		block_target_ext.block_source_exts.append(self)
