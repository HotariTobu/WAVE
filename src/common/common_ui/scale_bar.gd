class_name ScaleBar
extends Control

@export var intervals: PackedInt32Array = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000]
@export_range(1, 5) var major_count = 3

@export var font = ThemeDB.fallback_font
@export var font_size = ThemeDB.fallback_font_size

@onready var _camera = get_viewport().get_camera_2d() as PanZoomCamera

var _scale: float
var _last_scale: float

var _major_interval: int


func _ready():
	intervals.sort()


func _process(_delta):
	_scale = _camera.zoom_value
	if _last_scale == _scale:
		return

	_last_scale = _scale

	var scaled_width = size.x / _scale
	var major_interval_index = intervals.bsearch(scaled_width / major_count, false) - 1

	if major_interval_index < 0:
		_major_interval = 0
	else:
		_major_interval = intervals[major_interval_index]

	queue_redraw()


func _draw():
	var minor_width = _major_interval * _scale / 10

	var tick_height = size.y - font_size
	var tick_y = tick_height / 2

	for index in range(major_count * 10 + 1):
		var x = minor_width * index
		var y = 0.0 if index % 10 == 0 else tick_y
		draw_line(Vector2(x, y), Vector2(x, tick_height), modulate)

	var label_width = size.x / major_count
	var label_offset_x = label_width / 2

	for index in range(major_count + 1):
		var label = _major_interval * index
		var x = label * _scale

		draw_string(font, Vector2(x - label_offset_x, size.y), str(label), HORIZONTAL_ALIGNMENT_CENTER, label_width)
