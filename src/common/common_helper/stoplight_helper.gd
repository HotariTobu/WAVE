class_name StoplightHelper


var offset: float
var cycle: float
var durations: PackedFloat32Array
var cumulative_times: PackedFloat32Array


func _init(stoplight_offset: float, splits: Array):
	offset = stoplight_offset

	for split in splits:
		cycle += split.duration
		durations.append(split.duration)
		cumulative_times.append(cycle)


func calc_cycle_pos(time: float) -> float:
	return fposmod(time - offset, cycle)


func calc_split_index(cycle_pos: float) -> int:
	return cumulative_times.bsearch(cycle_pos)
