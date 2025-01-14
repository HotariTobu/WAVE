class_name Setting
extends Node

var bridge_color = Color("#26c7b7")
var bridge_width = 0.5

var lane_color = Color("#b2b2b2")
var lane_width = 1.5

var stoplight_color = Color("#fffdd4")
var stoplight_radius = 4.0
var stoplight_shape = SpotHelper.Shape.CIRCLE

var walker_head_length = 0.3
var walker_color = Color("#3bfa2d")

var vehicle_head_length = 2.0
var vehicle_color = Color("#fcba03")
var vehicle_width = 3.0

var pointer_area_radius = 10.0

var selected_color = Color("#1987e0")
var selecting_color = selected_color.lightened(0.5)
var selection_radius = 10.0

var block_targeted_color = Color("#f01616")
var block_targeting_color = block_targeted_color.lightened(0.5)

var force_default_bridge_traffic = true
var force_default_bridge_forward_rate = true
var force_default_bridge_width_limit = false

var default_bridge_traffic = 10.0
var default_bridge_forward_rate = 0.5
var default_bridge_width_limit = 6
var default_bridge_option_weight = 1.0

var force_default_lane_traffic = true
var force_default_lane_speed_limit = false

var default_lane_traffic = 1.0
var default_lane_speed_limit = 60
var default_lane_option_weight = 1.0

var default_stoplight_offset = 0.0
var default_split_count = 2
var default_split_duration = 60.0

var start_point_selecting_color = Color("#2aa846", 0.5)
var end_point_selecting_color = Color("#cc2944", 0.5)

var stoplight_sector_min_arc = 100.0
var stoplight_sector_max_radius = 100.0
var stoplight_sector_delta_angle_inv = 90 / TAU

var stoplight_sector_inactive_color = Color("#bdbdbd", 0.5)
var stoplight_sector_saturation = 0.5

var default_step_delta = 1
var default_max_step = 3600
var default_max_entry_step_offset = 10
var default_max_entry_step_gap = 10
var default_random_seed = 5

var default_walker_spawn_rate_before_start = 1.0
var default_walker_spawn_rate_after_start = 1.0

var default_walker_spawn_parameters = [
	{
		&"weight": 100.0,
		&"radius": 0.5,
		&"speed_range": {&"begin": 1.0, &"end": 5.0},
		&"speed_mean": 3.0,
		&"overtake_speed_range": {&"begin": 1.0, &"end": 5.0},
		&"overtake_speed_mean": 2.0,
		&"personal_distance_range": {&"begin": 0.3, &"end": 1.0},
		&"personal_distance_mean": 0.5,
		&"public_distance_range": {&"begin": 0.5, &"end": 3.0},
		&"public_distance_mean": 1.5,
	},
]

var default_vehicle_spawn_rate_before_start = 1.0
var default_vehicle_spawn_rate_after_start = 1.0

var default_vehicle_spawn_parameters = [
	{
		&"weight": 6.7,
		&"length": 2.5,
		&"high_speed_acceleration_range": {&"begin": 2.0, &"end": 5.0},
		&"high_speed_acceleration_mean": 3.0,
		&"high_speed_range": {&"begin": 70.0, &"end": 130.0},
		&"high_speed_mean": 100.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 150.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 1.0, &"end": 10.0},
		&"zero_speed_distance_mean": 3.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 15.0},
		&"half_speed_distance_mean": 6.0,
		&"high_speed_distance_range": {&"begin": 10.0, &"end": 100.0},
		&"high_speed_distance_mean": 60.0,
	},
	{
		&"weight": 6.7,
		&"length": 3.0,
		&"high_speed_acceleration_range": {&"begin": 2.0, &"end": 5.0},
		&"high_speed_acceleration_mean": 3.0,
		&"high_speed_range": {&"begin": 70.0, &"end": 130.0},
		&"high_speed_mean": 100.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 150.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 1.0, &"end": 10.0},
		&"zero_speed_distance_mean": 3.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 15.0},
		&"half_speed_distance_mean": 6.0,
		&"high_speed_distance_range": {&"begin": 10.0, &"end": 100.0},
		&"high_speed_distance_mean": 60.0,
	},
	{
		&"weight": 6.7,
		&"length": 3.4,
		&"high_speed_acceleration_range": {&"begin": 2.0, &"end": 5.0},
		&"high_speed_acceleration_mean": 3.0,
		&"high_speed_range": {&"begin": 70.0, &"end": 130.0},
		&"high_speed_mean": 100.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 150.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 1.0, &"end": 10.0},
		&"zero_speed_distance_mean": 3.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 15.0},
		&"half_speed_distance_mean": 6.0,
		&"high_speed_distance_range": {&"begin": 10.0, &"end": 100.0},
		&"high_speed_distance_mean": 60.0,
	},
	{
		&"weight": 138.3,
		&"length": 4.1,
		&"high_speed_acceleration_range": {&"begin": 2.0, &"end": 9.0},
		&"high_speed_acceleration_mean": 3.0,
		&"high_speed_range": {&"begin": 70.0, &"end": 130.0},
		&"high_speed_mean": 100.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 150.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 1.0, &"end": 10.0},
		&"zero_speed_distance_mean": 4.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 15.0},
		&"half_speed_distance_mean": 8.0,
		&"high_speed_distance_range": {&"begin": 10.0, &"end": 100.0},
		&"high_speed_distance_mean": 60.0,
	},
	{
		&"weight": 138.3,
		&"length": 4.7,
		&"high_speed_acceleration_range": {&"begin": 2.0, &"end": 9.0},
		&"high_speed_acceleration_mean": 3.0,
		&"high_speed_range": {&"begin": 70.0, &"end": 130.0},
		&"high_speed_mean": 100.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 150.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 1.0, &"end": 10.0},
		&"zero_speed_distance_mean": 4.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 15.0},
		&"half_speed_distance_mean": 8.0,
		&"high_speed_distance_range": {&"begin": 10.0, &"end": 100.0},
		&"high_speed_distance_mean": 60.0,
	},
	{
		&"weight": 138.3,
		&"length": 4.8,
		&"high_speed_acceleration_range": {&"begin": 2.0, &"end": 5.0},
		&"high_speed_acceleration_mean": 3.0,
		&"high_speed_range": {&"begin": 70.0, &"end": 130.0},
		&"high_speed_mean": 100.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 150.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 1.0, &"end": 10.0},
		&"zero_speed_distance_mean": 4.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 15.0},
		&"half_speed_distance_mean": 8.0,
		&"high_speed_distance_range": {&"begin": 10.0, &"end": 100.0},
		&"high_speed_distance_mean": 60.0,
	},
	{
		&"weight": 44.0,
		&"length": 5.0,
		&"high_speed_acceleration_range": {&"begin": 2.0, &"end": 5.0},
		&"high_speed_acceleration_mean": 3.0,
		&"high_speed_range": {&"begin": 70.0, &"end": 130.0},
		&"high_speed_mean": 100.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 150.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 1.0, &"end": 10.0},
		&"zero_speed_distance_mean": 4.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 15.0},
		&"half_speed_distance_mean": 8.0,
		&"high_speed_distance_range": {&"begin": 10.0, &"end": 100.0},
		&"high_speed_distance_mean": 60.0,
	},
	{
		&"weight": 77.0,
		&"length": 6.0,
		&"high_speed_acceleration_range": {&"begin": 2.0, &"end": 5.0},
		&"high_speed_acceleration_mean": 3.0,
		&"high_speed_range": {&"begin": 70.0, &"end": 130.0},
		&"high_speed_mean": 100.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 150.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 1.0, &"end": 10.0},
		&"zero_speed_distance_mean": 4.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 15.0},
		&"half_speed_distance_mean": 8.0,
		&"high_speed_distance_range": {&"begin": 10.0, &"end": 100.0},
		&"high_speed_distance_mean": 60.0,
	},
	{
		&"weight": 77.0,
		&"length": 7.0,
		&"high_speed_acceleration_range": {&"begin": 1.0, &"end": 3.0},
		&"high_speed_acceleration_mean": 1.8,
		&"high_speed_range": {&"begin": 70.0, &"end": 110.0},
		&"high_speed_mean": 80.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 120.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 3.0, &"end": 10.0},
		&"zero_speed_distance_mean": 6.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 20.0},
		&"half_speed_distance_mean": 12.0,
		&"high_speed_distance_range": {&"begin": 20.0, &"end": 100.0},
		&"high_speed_distance_mean": 80.0,
	},
	{
		&"weight": 28.5,
		&"length": 8.0,
		&"high_speed_acceleration_range": {&"begin": 1.0, &"end": 3.0},
		&"high_speed_acceleration_mean": 1.8,
		&"high_speed_range": {&"begin": 70.0, &"end": 110.0},
		&"high_speed_mean": 80.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 120.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 3.0, &"end": 10.0},
		&"zero_speed_distance_mean": 6.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 20.0},
		&"half_speed_distance_mean": 12.0,
		&"high_speed_distance_range": {&"begin": 20.0, &"end": 100.0},
		&"high_speed_distance_mean": 80.0,
	},
	{
		&"weight": 28.5,
		&"length": 9.0,
		&"high_speed_acceleration_range": {&"begin": 1.0, &"end": 3.0},
		&"high_speed_acceleration_mean": 1.8,
		&"high_speed_range": {&"begin": 70.0, &"end": 110.0},
		&"high_speed_mean": 80.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 120.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 3.0, &"end": 10.0},
		&"zero_speed_distance_mean": 6.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 20.0},
		&"half_speed_distance_mean": 12.0,
		&"high_speed_distance_range": {&"begin": 20.0, &"end": 100.0},
		&"high_speed_distance_mean": 80.0,
	},
	{
		&"weight": 24.5,
		&"length": 10.0,
		&"high_speed_acceleration_range": {&"begin": 1.0, &"end": 3.0},
		&"high_speed_acceleration_mean": 1.8,
		&"high_speed_range": {&"begin": 70.0, &"end": 110.0},
		&"high_speed_mean": 80.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 120.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 3.0, &"end": 10.0},
		&"zero_speed_distance_mean": 6.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 20.0},
		&"half_speed_distance_mean": 12.0,
		&"high_speed_distance_range": {&"begin": 20.0, &"end": 100.0},
		&"high_speed_distance_mean": 80.0,
	},
	{
		&"weight": 24.5,
		&"length": 11.0,
		&"high_speed_acceleration_range": {&"begin": 1.0, &"end": 3.0},
		&"high_speed_acceleration_mean": 1.8,
		&"high_speed_range": {&"begin": 70.0, &"end": 110.0},
		&"high_speed_mean": 80.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 120.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 3.0, &"end": 10.0},
		&"zero_speed_distance_mean": 6.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 20.0},
		&"half_speed_distance_mean": 12.0,
		&"high_speed_distance_range": {&"begin": 20.0, &"end": 100.0},
		&"high_speed_distance_mean": 80.0,
	},
	{
		&"weight": 20.0,
		&"length": 12.0,
		&"high_speed_acceleration_range": {&"begin": 1.0, &"end": 3.0},
		&"high_speed_acceleration_mean": 1.8,
		&"high_speed_range": {&"begin": 70.0, &"end": 110.0},
		&"high_speed_mean": 80.0,
		&"max_speed_range": {&"begin": 80.0, &"end": 120.0},
		&"max_speed_mean": 110.0,
		&"zero_speed_distance_range": {&"begin": 3.0, &"end": 10.0},
		&"zero_speed_distance_mean": 6.0,
		&"half_speed_distance_range": {&"begin": 5.0, &"end": 20.0},
		&"half_speed_distance_mean": 12.0,
		&"high_speed_distance_range": {&"begin": 20.0, &"end": 100.0},
		&"high_speed_distance_mean": 80.0,
	},
]
