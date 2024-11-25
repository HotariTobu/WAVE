class_name PlayerStoplightData

var offset: float

var cycle: float
var durations: PackedFloat32Array


func _init(stoplight: StoplightData, data_of: Callable):
	offset = stoplight.offset

	var splits = stoplight.split_ids.map(data_of)

	for split in splits:
		cycle += split.duration
		durations.append(split.duration)
