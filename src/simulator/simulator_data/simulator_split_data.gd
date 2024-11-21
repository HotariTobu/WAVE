class_name SimulatorSplitData
extends SimulatorContentData

var duration: float
var block_targets: Array[SimulatorContentData]

var stoplight: SimulatorStoplightData


func assign(content: ContentData, data_of: Callable) -> void:
	super(content, data_of)
	var split = content as SplitData
	duration = split.duration
	assign_array(&"block_targets", split.block_target_ids, data_of)

	for block_target in block_targets:
		block_target.block_sources.append(self)
