class_name SimulatorSpaceData
extends SimulatorSegmentsData

var block_targets: Array[SimulatorContentData]

var block_sources: Array[SimulatorContentData]


func assign(content: ContentData, data_of: Callable) -> void:
	super(content, data_of)
	var space = content as SpaceData
	assign_array(&"block_targets", space.block_target_ids, data_of)

	for block_target in block_targets:
		block_target.block_sources.append(self)
