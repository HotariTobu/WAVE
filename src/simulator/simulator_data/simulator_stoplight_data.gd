class_name SimulatorStoplightData
extends SimulatorVertexData

var offset: float
var splits: Array[SimulatorSplitData]


func assign(content: ContentData, data_of: Callable) -> void:
	super(content, data_of)
	var stoplight = content as StoplightData
	offset = stoplight.offset
	assign_array(&"splits", stoplight.split_ids, data_of)

	for split in splits:
		split.stoplight = self
