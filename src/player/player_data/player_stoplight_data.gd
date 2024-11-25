class_name PlayerStoplightData

var offset: float
var splits: Array[SplitData]


func _init(stoplight: StoplightData, data_of: Callable):
	offset = stoplight.offset
	splits.assign(stoplight.split_ids.map(data_of))
