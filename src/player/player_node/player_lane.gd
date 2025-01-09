class_name PlayerLane
extends PlayerAnimatable

var _block_step_set: Set
var _is_blocked: bool


func _init(lane: LaneData):
	super(LaneData.to_dict(lane))

	var player_lane = player_global.content_db.player_data_of(lane.id) as PlayerLaneData
	_collision_points = player_lane.points

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
	var color: Color
	if selecting:
		color = setting.selecting_color
	elif selected:
		color = setting.selected_color
	elif _is_blocked:
		color = setting.block_targeted_color
	else:
		color = setting.lane_color

	LaneHelper.draw_to(self, _collision_points, color, setting.lane_width)
