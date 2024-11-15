class_name EditorStoplightCore
extends EditorContent

var is_opened: bool

var _sectors: Array[EditorStoplightSector]:
	get:
		return _sectors
	set(next):
		var prev = _sectors
		_unbind_sectors(prev)
		_bind_sectors(next)
		_sectors = next
		_update_sectors()

@onready var _selectable_owner = get_tree().root


func _init(stoplight: StoplightData):
	super(stoplight, EditorPhysicsLayer.STOPLIGHT_CORE)

	add_child(create_point())


func _ready():
	super()
	
	_source.bind(&"pos").to(self, &"position")
	_source.bind(&"split_ids").using(_get_sectors_of).to(self, &"_sectors")

func _draw():
	Spot.draw_to(self, setting.stoplight_color, setting.stoplight_radius, setting.stoplight_shape)

	var color: Color
	if selecting:
		color = setting.stoplight_selecting_color
	elif selected:
		color = setting.stoplight_selected_color
	else:
		return

	var radius = setting.selection_radius / zoom_factor
	draw_circle(Vector2.ZERO, radius, color)


func _get_sectors_of(split_ids: Array) -> Array[EditorStoplightSector]:
	var sectors = split_ids.map(_get_sector_of)
	return Array(sectors, TYPE_OBJECT, &"Area2D", EditorStoplightSector)


func _get_sector_of(split_id: StringName) -> EditorStoplightSector:
	return _selectable_owner.get_node("%" + split_id)


func _bind_sectors(sectors: Array[EditorStoplightSector]):
	var core_source = _editor_global.source_db.get_or_add(self)
	for sector in sectors:
		var split = sector.data as SplitData
		var split_source = _editor_global.source_db.get_or_add(split)
		core_source.bind(&"is_opened").to(sector, &"visible")
		_source.bind(&"pos").to(sector, &"position")
		split_source.add_callback(&"duration", _update_sectors)

func _unbind_sectors(sectors: Array[EditorStoplightSector]):
	var core_source = _editor_global.source_db.get_or_add(self)
	for sector in sectors:
		var split = sector.data as SplitData
		var split_source = _editor_global.source_db.get_or_add(split)
		core_source.unbind(&"is_opened").from(sector, &"visible")
		_source.unbind(&"pos").from(sector, &"position")
		split_source.remove_callback(&"duration", _update_sectors)


func _update_sectors():
	var cycle = 0.0
	var min_duration = INF

	for sector in _sectors:
		var split = sector.data as SplitData

		var duration = split.duration
		cycle += duration
		if min_duration > duration:
			min_duration = duration

	var angle_factor = TAU / cycle

	var min_angle = min_duration * angle_factor
	var sector_radius = setting.stoplight_sector_min_arc / min_angle
	if sector_radius > setting.stoplight_sector_max_radius:
		sector_radius = setting.stoplight_sector_max_radius

	var sum = 0.0

	for sector in _sectors:
		var split = sector.data as SplitData

		var start_angle = sum * angle_factor
		sum += split.duration
		var end_angle = sum * angle_factor

		sector.update(sector_radius, start_angle, end_angle)
