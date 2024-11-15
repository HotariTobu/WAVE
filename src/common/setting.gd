class_name Setting
extends Node

var lane_color = Color("b2b2b2")
var lane_width = 2.0

var stoplight_color = Color("fffdd4")
var stoplight_radius = 4.0
var stoplight_shape = Spot.Shape.CIRCLE

var selection_radius = 10.0

var preview_lane_color = Color("b2b2b2")

var default_lane_speed_limit = 60
var default_option_weight = 1.0

var lane_selecting_color = Color("0f08")
var lane_selected_color = Color("0f0")

var lane_start_point_selecting_color = Color("f008")
var lane_start_point_selected_color = Color("f00")

var lane_way_point_selecting_color = Color("0f08")
var lane_way_point_selected_color = Color("0f0")

var lane_end_point_selecting_color = Color("00f8")
var lane_end_point_selected_color = Color("00f")

var default_stoplight_offset = 0.0
var default_split_count = 2
var default_split_duration = 60.0

var stoplight_sector_min_arc = 100.0
var stoplight_sector_max_radius = 100.0
var stoplight_sector_delta_angle_inv = 40 / TAU

var stoplight_selecting_color = Color("ff08")
var stoplight_selected_color = Color("ff0")

var stoplight_sector_color = Color("828282a0")

var block_line_color = Color("6ed1f0")
