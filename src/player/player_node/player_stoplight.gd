class_name PlayerStoplight
extends PlayerAnimatable

var _stoplight_helper: StoplightHelper
var _sector_helpers: Array[SectorHelper]
var _width: float

var _sector_index: int
var _sector_weight: float


func _init(stoplight: StoplightData):
	position = stoplight.pos

	var player_stoplight = player_global.content_db.player_data_of(stoplight.id) as PlayerStoplightData
	_stoplight_helper = StoplightHelper.new(stoplight.offset, player_stoplight.splits)
	_sector_helpers = SectorHelper.get_sector_helpers(stoplight.offset, _stoplight_helper.durations)
	_width = setting.selection_radius

	var radius = setting.selection_radius * 2

	for sector_helper in _sector_helpers:
		sector_helper.radius = radius


func _process(_delta):
	var cycle_pos = _stoplight_helper.calc_cycle_pos(player_global.time)
	var split_index = _stoplight_helper.calc_split_index(cycle_pos)
	var cumulative_time = _stoplight_helper.cumulative_times[split_index]
	var duration = _stoplight_helper.durations[split_index]

	_sector_index = split_index
	_sector_weight = (cumulative_time - cycle_pos) / duration

	queue_redraw()


func _draw():
	var sector_helper = _sector_helpers[_sector_index]
	draw_circle(Vector2.ZERO, sector_helper.radius, setting.stoplight_sector_inactive_color, false, _width)
	sector_helper.draw_to(self, _width, _sector_weight)
