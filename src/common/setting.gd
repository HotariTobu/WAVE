class_name Setting
extends Node

var lane_color = Color("#b2b2b2")
var lane_width = 2.0

var stoplight_color = Color("#fffdd4")
var stoplight_radius = 4.0
var stoplight_shape = Spot.Shape.CIRCLE

var selected_color = Color("#1987e0")
var selecting_color = Color(selected_color, 0.5)
var selection_radius = 10.0

var default_lane_traffic = 1.0
var default_lane_speed_limit = 60
var default_option_weight = 1.0

var default_stoplight_offset = 0.0
var default_split_count = 2
var default_split_duration = 60.0

var preview_lane_color = Color("#b2b2b2")

var lane_start_point_selecting_color = Color("#2aa846", 0.5)
var lane_end_point_selecting_color = Color("#cc2944", 0.5)

var stoplight_sector_min_arc = 100.0
var stoplight_sector_max_radius = 100.0
var stoplight_sector_delta_angle_inv = 40 / TAU

var stoplight_sector_color = Color("#bdbdbd", 0.5)
var stoplight_sector_saturation = 0.5

var lane_block_targeted_color = Color("#f01616")
var lane_block_targeting_color = Color(lane_block_targeted_color, 0.5)

var default_step_delta = 10
var default_max_step = 10

var default_vehicle_spawn_before_start: = true
var default_vehicle_spawn_after_start = true
var default_vehicle_spawn_limit = 1
