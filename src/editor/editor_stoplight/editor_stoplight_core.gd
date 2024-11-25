class_name EditorStoplightCore
extends EditorContent

var opened: bool

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

	add_child(create_point())


func _enter_tree():
	_source.bind(&"pos").to(self, &"position")
	_source.bind(&"split_ids").using(_get_sectors_of).to(self, &"_sectors")

	var core_source = _editor_global.source_db.get_or_add(self, &"notified")
	core_source.bind(&"selected").to(core_source, &"opened")


func _exit_tree():
	_source.unbind(&"pos").from(self, &"position")
	_source.unbind(&"split_ids").from(self, &"_sectors")

	var core_source = _editor_global.source_db.get_or_add(self, &"notified")
	core_source.unbind(&"selected").from(core_source, &"opened")


func _draw():
	Spot.draw_to(self, setting.stoplight_color, setting.stoplight_radius, setting.stoplight_shape)

	var color: Color
	if selecting:
		color = setting.selecting_color
	elif selected:
		color = setting.selected_color
	else:
		return

	var radius = setting.selection_radius / zoom_factor
	draw_circle(Vector2.ZERO, radius, color)


func move_by(offset: Vector2):
	_source.pos += offset


func _get_sectors_of(split_ids: Array) -> Array[EditorStoplightSector]:
	var sectors = split_ids.map(_editor_global.get_content_node)
	return Array(sectors, TYPE_OBJECT, &"Area2D", EditorStoplightSector)


func _bind_sectors(next_sectors: Array[EditorStoplightSector]):
	var unify_converter = UnifyConverter.from_property(self, &"selected", true)
	var core_source = _editor_global.source_db.get_or_add(self, &"notified")

	for sector in next_sectors:
		_source.bind(&"pos").to(sector, &"position")

		var sector_source = _editor_global.source_db.get_or_add(sector, &"notified")
		sector_source.bind(&"selected").using(unify_converter).to(core_source, &"opened")
		core_source.bind(&"opened").to(sector, &"visible")

		var split = sector.data as SplitData
		var split_source = _editor_global.source_db.get_or_add(split)
		split_source.add_callback(&"duration", _update_sectors)


func _unbind_sectors(prev_sectors: Array[EditorStoplightSector]):
	var core_source = _editor_global.source_db.get_or_add(self, &"notified")

	for sector in prev_sectors:
		_source.unbind(&"pos").from(sector, &"position")

		var sector_source = _editor_global.source_db.get_or_add(sector, &"notified")
		sector_source.unbind(&"selected").from(core_source, &"opened")
		core_source.unbind(&"opened").from(sector, &"visible")

		var split = sector.data as SplitData
		var split_source = _editor_global.source_db.get_or_add(split)
		split_source.remove_callback(&"duration", _update_sectors)


func _update_sectors():
	var sectors = _sectors
	var durations: PackedFloat32Array

	for sector in sectors:
		var split = sector.data as SplitData
		durations.append(split.duration)

	var sector_helpers = Stoplight.get_sector_helpers(durations)

	for index in range(len(sectors)):
		var sector = sectors[index]
		var sector_helper = sector_helpers[index]
		sector.update(sector_helper)
