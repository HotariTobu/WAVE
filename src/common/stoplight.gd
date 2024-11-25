class_name Stoplight

const HALF_PI = PI / 2


static func calc_sector_info(durations: PackedFloat32Array) -> SectorInfo:
	var sector_info = SectorInfo.new()

	if durations.is_empty():
		return sector_info

	var cycle = 0.0
	var min_duration = INF

	for duration in durations:
		cycle += duration
		if min_duration > duration:
			min_duration = duration

	var angle_factor = TAU / cycle

	var min_angle = min_duration * angle_factor
	sector_info.radius = setting.stoplight_sector_min_arc / min_angle
	if sector_info.radius > setting.stoplight_sector_max_radius:
		sector_info.radius = setting.stoplight_sector_max_radius

	var sum = 0.0

	for duration in durations:
		var angle = AngleRange.new()
		angle.start = sum * angle_factor - HALF_PI
		sum += duration
		angle.end = sum * angle_factor - HALF_PI
		sector_info.angles.append(angle)

	return sector_info


class SectorInfo:
	var radius: float
	var angles: Array[AngleRange]


class AngleRange:
	var start: float
	var end: float
