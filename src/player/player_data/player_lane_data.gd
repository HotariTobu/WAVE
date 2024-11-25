class_name PlayerLaneData
extends PlayerSpaceData

const HEAD_LANE_OVER_WEIGHT = 100

func _init(lane: LaneData, data_of: Callable):
	super(lane, data_of)

	if lane.next_option_dict.is_empty():
		var pos0 = points[-2]
		var pos1 = points[-1]
		var pos2 = pos0.lerp(pos1, HEAD_LANE_OVER_WEIGHT)
		curve.add_point(pos2)
