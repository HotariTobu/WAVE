extends EditorTool

const TOOL_DISPLAY_NAME = "Measure tool"
const TOOL_STATUS_HINT = "Left drag: show distance"

@export var font = ThemeDB.fallback_font
@export var font_size = ThemeDB.fallback_font_size

var _start_pos = Vector2.INF
var _end_pos = Vector2.INF

var _ruler_segment = RulerSegment.new(self)


func _init():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(_ruler_segment)
	add_child(canvas_layer)


func _ready():
	set_process(false)
	set_process_unhandled_input(false)


func _process(_delta):
	_ruler_segment.queue_redraw()


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_end_pos = get_local_mouse_position()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_start_pos = get_local_mouse_position()
			_end_pos = Vector2.INF

	elif event.is_action_pressed(&"ui_cancel"):
		_cancel()


func get_display_name() -> String:
	return TOOL_DISPLAY_NAME


func get_status_hint() -> String:
	return TOOL_STATUS_HINT


func activate() -> void:
	set_process(true)
	set_process_unhandled_input(true)


func deactivate() -> void:
	set_process(false)
	set_process_unhandled_input(false)

	_cancel()
	_ruler_segment.queue_redraw()


func _cancel():
	_start_pos = Vector2.INF
	_end_pos = Vector2.INF


class RulerSegment:
	extends Node2D

	var _tool

	func _init(tool):
		_tool = tool

	func _draw():
		if _tool._start_pos == Vector2.INF or _tool._end_pos == Vector2.INF:
			return

		var distance = _tool._start_pos.distance_to(_tool._end_pos)
		var label = "%.2f" % distance

		var tool_transform = _tool.get_global_transform_with_canvas()
		var start_pos = tool_transform * _tool._start_pos
		var end_pos = tool_transform * _tool._end_pos

		draw_line(start_pos, end_pos, modulate)
		draw_string(_tool.font, end_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, _tool.font_size)
