class_name PlayerLane
extends Node2D

var _lane: PlayerLaneData


func _init(lane: LaneData):
	_lane = player_global.content_db.player_data_of(lane.id) as PlayerLaneData


func _draw():
	Lane.draw_to(self, _lane.points, setting.lane_color, setting.lane_width)
