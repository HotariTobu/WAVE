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

var default_step_delta = 1
var default_max_step = 10

var default_vehicle_spawn_before_start := true
var default_vehicle_spawn_after_start = true
var default_vehicle_spawn_limit = 1

var default_vehicle_length_options = [
	ParameterData.RandomOption.new(2.5, 6.7),
	ParameterData.RandomOption.new(3.0, 6.7),
	ParameterData.RandomOption.new(3.4, 6.7),
	ParameterData.RandomOption.new(4.1, 138.3),
	ParameterData.RandomOption.new(4.7, 138.3),
	ParameterData.RandomOption.new(4.8, 138.3),
	ParameterData.RandomOption.new(5.0, 44),
	ParameterData.RandomOption.new(6.0, 77),
	ParameterData.RandomOption.new(7.0, 77),
	ParameterData.RandomOption.new(8.0, 28.5),
	ParameterData.RandomOption.new(9.0, 28.5),
	ParameterData.RandomOption.new(10.0, 24.5),
	ParameterData.RandomOption.new(11.0, 24.5),
	ParameterData.RandomOption.new(12.0, 20),
] as Array[ParameterData.RandomOption]

var default_vehicle_relative_speed_range = ParameterData.IntRange.new(-30, 30)
var default_vehicle_relative_speed_mean = 10
var default_vehicle_max_speed_range = ParameterData.IntRange.new(80, 150)
var default_vehicle_max_speed_mean = 110
var default_vehicle_min_following_distance_range = ParameterData.IntRange.new(1, 5)
var default_vehicle_min_following_distance_mean = 2
var default_vehicle_max_following_distance_range = ParameterData.IntRange.new(10, 100)
var default_vehicle_max_following_distance_mean = 50
