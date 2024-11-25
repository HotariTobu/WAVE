class_name SectorHelper

const HALF_PI = PI / 2

var radius: float
var start_angle: float
var end_angle: float
var point_count: int
var color: Color


func draw_to(canvas: CanvasItem, width: float, weight: float = 1.0):
	var weighted_angle = lerpf(end_angle, start_angle, weight)
	canvas.draw_arc(Vector2.ZERO, radius, weighted_angle, end_angle, point_count, color, width)


static func get_sector_helpers(offset: float, durations: PackedFloat32Array) -> Array[SectorHelper]:
	var sector_helpers: Array[SectorHelper]

	if durations.is_empty():
		return sector_helpers

	var cycle = 0.0
	var min_duration = INF

	for duration in durations:
		cycle += duration
		if min_duration > duration:
			min_duration = duration

	var angle_factor = TAU / cycle

	var min_angle = min_duration * angle_factor
	var sector_radius = setting.stoplight_sector_min_arc / min_angle
	if sector_radius > setting.stoplight_sector_max_radius:
		sector_radius = setting.stoplight_sector_max_radius

	var offset_angle = offset * angle_factor - HALF_PI

	var sum = 0.0

	for duration in durations:
		var sector_helper = SectorHelper.new()
		sector_helper.radius = sector_radius

		sector_helper.start_angle = sum * angle_factor + offset_angle
		sum += duration
		sector_helper.end_angle = sum * angle_factor + offset_angle

		var central_angle = sector_helper.end_angle - sector_helper.start_angle
		sector_helper.point_count = floori(central_angle * setting.stoplight_sector_delta_angle_inv)

		var hue = sector_helper.start_angle / TAU
		sector_helper.color = Color.from_hsv(hue, setting.stoplight_sector_saturation, 1.0)

		sector_helpers.append(sector_helper)

	return sector_helpers
