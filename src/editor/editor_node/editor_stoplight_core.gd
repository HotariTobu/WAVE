class_name EditorStoplightCore
extends EditorScalable

var opened: bool

var _self_source: BindingSource

var _sectors: Array[EditorStoplightSector]:
	get:
		return _sectors
	set(next):
		var prev = _sectors
		_unbind_sectors(prev)
		_bind_sectors(next)
		_sectors = next
		_update_sectors()


func _init(stoplight: StoplightData):
	super(stoplight, EditorPhysicsLayer.STOPLIGHT_CORE)
	_collision_points = [Vector2.ZERO]

	_self_source = _editor_global.source_db.get_or_add(self, &"notified")


func _ready():
	super()
	set_process(true)


func _enter_tree():
	_source.bind(&"pos").to(self, &"position")
	_source.add_callback(&"offset", _update_sectors)
	_source.bind(&"split_ids").using(_get_sectors_of).to(self, &"_sectors")
	_self_source.bind(&"selected").to(_self_source, &"opened")


func _exit_tree():
	_source.unbind(&"pos").from(self, &"position")
	_source.remove_callback(&"offset", _update_sectors)
	_source.unbind(&"split_ids").from(self, &"_sectors")
	_self_source.unbind(&"selected").from(_self_source, &"opened")


func _scaled_draw(drawing_scale: float) -> void:
	var color: Color
	if selecting:
		color = setting.selecting_color
	elif selected:
		color = setting.selected_color
	else:
		color = setting.stoplight_color

	var radius = setting.stoplight_radius / drawing_scale
	SpotHelper.draw_to(self, color, radius, setting.stoplight_shape)


func _get_sectors_of(split_ids: Array) -> Array[EditorStoplightSector]:
	var sectors = split_ids.map(_editor_global.content_node_of)
	return Array(sectors, TYPE_OBJECT, &"Area2D", EditorStoplightSector)


func _bind_sectors(next_sectors: Array[EditorStoplightSector]):
	var unify_converter = UnifyConverter.from_property(self, &"selected", true)

	for sector in next_sectors:
		_source.bind(&"pos").to(sector, &"position")

		var sector_source = _editor_global.source_db.get_or_add(sector, &"notified")
		sector_source.bind(&"selected").using(unify_converter).to(_self_source, &"opened")
		_self_source.bind(&"opened").to(sector, &"visible")

		var split = sector.data as SplitData
		var split_source = _editor_global.source_db.get_or_add(split)
		split_source.add_callback(&"duration", _update_sectors)


func _unbind_sectors(prev_sectors: Array[EditorStoplightSector]):
	for sector in prev_sectors:
		_source.unbind(&"pos").from(sector, &"position")

		var sector_source = _editor_global.source_db.get_or_add(sector, &"notified")
		sector_source.unbind(&"selected").from(_self_source, &"opened")
		_self_source.unbind(&"opened").from(sector, &"visible")

		var split = sector.data as SplitData
		var split_source = _editor_global.source_db.get_or_add(split)
		split_source.remove_callback(&"duration", _update_sectors)


func _update_sectors():
	var sectors = _sectors
	var durations: PackedFloat32Array

	for sector in sectors:
		var split = sector.data as SplitData
		durations.append(split.duration)

	var sector_helpers = SectorHelper.get_sector_helpers(data.offset, durations)

	for index in range(len(sectors)):
		var sector = sectors[index]
		var sector_helper = sector_helpers[index]
		sector.update(sector_helper)
