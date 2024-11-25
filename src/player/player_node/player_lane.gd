class_name PlayerLane
extends Node2D

var _points: PackedVector2Array


func _init(lane: LaneData):
	var player_lane = player_global.content_db.player_data_of(lane.id) as PlayerLaneData
	_points = player_lane.points


func _draw():
	LaneHelper.draw_to(self, _points, setting.lane_color, setting.lane_width)
