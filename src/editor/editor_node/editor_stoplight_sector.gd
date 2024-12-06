class_name EditorStoplightSector
extends EditorScalable

var _sector_helper: SectorHelper

var _selecting_color: Color
var _selected_color: Color


func _init(split: SplitData):
	super(split, EditorPhysicsLayer.STOPLIGHT_SECTOR)


func _scaled_draw(drawing_scale: float) -> void:
	if _sector_helper.point_count < 2:
		return

	var color: Color
	if selecting:
		_sector_helper.color = _selecting_color
	elif selected:
		_sector_helper.color = _selected_color
	else:
		_sector_helper.color = setting.stoplight_sector_inactive_color

	var width = setting.selection_radius / drawing_scale
	_sector_helper.draw_to(self, width)


func update(sector_helper: SectorHelper):
	_sector_helper = sector_helper

	_selecting_color = Color(sector_helper.color, 0.5)
	_selected_color = sector_helper.color

	var point_count = sector_helper.point_count
	var segment_count = point_count - 1

	var points: PackedVector2Array
	points.resize(point_count)

	for point_index in range(point_count):
		var weight = float(point_index) / segment_count
		var angle = lerpf(sector_helper.start_angle, sector_helper.end_angle, weight)

		var point = Vector2.from_angle(angle) * sector_helper.radius
		points[point_index] = point

	_collision_points = points


func _on_visibility_changed():
	super()
	set_process(is_visible_in_tree())
