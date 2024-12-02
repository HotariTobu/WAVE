class_name Setting
extends Node

var lane_color = Color("#b2b2b2")
var lane_width = 1.5

var stoplight_color = Color("#fffdd4")
var stoplight_radius = 4.0
var stoplight_shape = SpotHelper.Shape.CIRCLE

var vehicle_head_length = 2.0
var vehicle_color = Color("#fcba03")
var vehicle_width = 3.0

var pointer_area_radius = 10.0

var selected_color = Color("#1987e0")
var selecting_color = Color(selected_color, 0.5)
var selection_radius = 10.0

var force_default_lane_traffic = true
var force_default_lane_speed_limit = false

var default_lane_traffic = 1.0
var default_lane_speed_limit = 60
var default_lane_option_weight = 1.0

var default_stoplight_offset = 0.0
var default_split_count = 2
var default_split_duration = 60.0

var preview_lane_color = Color("#b2b2b2")

var lane_start_point_selecting_color = Color("#2aa846", 0.5)
var lane_end_point_selecting_color = Color("#cc2944", 0.5)

var stoplight_sector_min_arc = 100.0
var stoplight_sector_max_radius = 100.0
var stoplight_sector_delta_angle_inv = 90 / TAU

var stoplight_sector_inactive_color = Color("#bdbdbd", 0.5)
var stoplight_sector_saturation = 0.5

var lane_block_targeted_color = Color("#f01616")
var lane_block_targeting_color = Color(lane_block_targeted_color, 0.5)

var default_step_delta = 1
var default_max_step = 100
var default_random_seed = 5

var default_vehicle_spawn_before_start = true
var default_vehicle_spawn_after_start = true
var default_vehicle_spawn_rate = 0.8

var default_vehicle_length_options = [
	{&"value": 2.5, &"weight": 6.7},
	{&"value": 3.0, &"weight": 6.7},
	{&"value": 3.4, &"weight": 6.7},
	{&"value": 4.1, &"weight": 138.3},
	{&"value": 4.7, &"weight": 138.3},
	{&"value": 4.8, &"weight": 138.3},
	{&"value": 5.0, &"weight": 44},
	{&"value": 6.0, &"weight": 77},
	{&"value": 7.0, &"weight": 77},
	{&"value": 8.0, &"weight": 28.5},
	{&"value": 9.0, &"weight": 28.5},
	{&"value": 10.0, &"weight": 24.5},
	{&"value": 11.0, &"weight": 24.5},
	{&"value": 12.0, &"weight": 20},
]

var default_vehicle_high_speed_acceleration_range = {&"begin": 1, &"end": 9}
var default_vehicle_high_speed_acceleration_mean = 3

var default_vehicle_high_speed_range = {&"begin": 70, &"end": 130}
var default_vehicle_high_speed_mean = 100
var default_vehicle_max_speed_range = {&"begin": 80, &"end": 150}
var default_vehicle_max_speed_mean = 110

var default_vehicle_zero_speed_distance_range = {&"begin": 1, &"end": 5}
var default_vehicle_zero_speed_distance_mean = 2
var default_vehicle_high_speed_distance_range = {&"begin": 10, &"end": 100}
var default_vehicle_high_speed_distance_mean = 60
