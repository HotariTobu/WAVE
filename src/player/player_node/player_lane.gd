class_name PlayerLane
extends Node2D

var _points: PackedVector2Array

var _block_step_set: Set
var _is_blocked: bool


func _init(lane: LaneData):
	var player_lane = player_global.content_db.player_data_of(lane.id) as PlayerLaneData
	_points = player_lane.points

	var block_steps = player_global.simulation.block_history.get_or_add(lane.id, [])
	_block_step_set = Set.from_array(block_steps)


func _ready():
	set_process(not _block_step_set.is_empty())


func _process(_delta):
	var is_block = _block_step_set.has(player_global.prev_step)
	if _is_blocked == is_block:
		return

	_is_blocked = is_block
	queue_redraw()


func _draw():
	var color = setting.lane_block_targeted_color if _is_blocked else setting.lane_color
	LaneHelper.draw_to(self, _points, color, setting.lane_width)
