class_name Agent
extends Node2D

var head_length: float
var length: float
var width: float
var color: Color

func _draw():
	var width_half = width / 2
	var points = [
		Vector2.ZERO,
		Vector2(-head_length, width_half),
		Vector2(-length, width_half),
		Vector2(-length, -width_half),
		Vector2(-head_length, -width_half),
	]
	draw_polygon(points, [color])
	
