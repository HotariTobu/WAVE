class_name PlayerLane
extends Node2D

var _points: PackedVector2Array


func _init(lane: LaneData):
	var vertices = lane.vertex_ids.map(player_global.content_db.data_of)
	var points = vertices.map(VertexData.pos_of)
	_points = points


func _draw():
	Lane.draw_to(self, _points, setting.lane_color, setting.lane_width)
