class_name EditorStoplight
extends Stoplight

signal notified(property: StringName)

var selecting: bool = false:
	get:
		return selecting
	set(value):
		selecting = value
		_update_selecting()

var opened: bool = false:
	get:
		return opened
	set(value):
		opened = value
		_update_sectors()

var _sectors: Array[EditorStoplightSector] = []:
	get:
		return _sectors
	set(next):
		var prev = _sectors

		for child in prev:
			child.queue_free()

		for child in next:
			add_child(child)

		_sectors = next

func _init():
	offset = 0
	splits = []

	add_split()
	add_split()

	_setup_collision_shapes.call_deferred()

func from_dict(dict: Dictionary):
	super(dict)

	for index in range(len(splits)):
		var split = splits[index]
		splits[index] = Split.new(split)

func add_split():
	add_split_at(len(splits))

func add_split_at(index: int):
	var split = Stoplight.Split.new()
	split.duration = 60
	splits.insert(index, Split.new(split))
	notified.emit(&'splits')

func remove_split():
	remove_split_at(len(splits) -1)

func remove_split_at(index: int):
	var split = splits.pop_at(index)
	for block_target in split.block_targets:
		block_target.block_sources.erase(split)
	notified.emit(&'splits')

func _update_selecting():
	for child in get_children():
		var item = child as EditorSelectable
		item.selecting = selecting

func _setup_collision_shapes():
	var core = EditorStoplightCore.new(self)
	add_child(core)

func _update_sectors():
	for split in splits:
		if split.selecting_changed.is_connected(_on_split_selecting_changed):
			split.selecting_changed.disconnect(_on_split_selecting_changed)
	
	if not opened:
		_sectors = []
		return

	var cycle = 0.0
	var min_duration = INF

	for split in splits:
		var duration = split.duration
		cycle += duration
		if min_duration > duration:
			min_duration = duration

	var angle_factor = TAU / cycle

	var min_angle = min_duration * angle_factor
	var sector_radius = setting.stoplight_sector_min_arc / min_angle
	if sector_radius > setting.stoplight_sector_max_radius:
		sector_radius = setting.stoplight_sector_max_radius

	var len_splits = len(splits)
	var sum = 0.0
	var sectors: Array[EditorStoplightSector] = []
	sectors.resize(len_splits)

	for split_index in range(len_splits):
		var split = splits[split_index]

		var start_angle = sum * angle_factor
		sum += split.duration
		var end_angle = sum * angle_factor

		var sector = EditorStoplightSector.new(self, split_index, sector_radius, start_angle, end_angle)
		sectors[split_index] = sector

		split.selecting_changed.connect(_on_split_selecting_changed.bind(split_index))

	_sectors = sectors

func _on_split_selecting_changed(new_value: bool, split_index: int):
	var sectors = _sectors
	if len(sectors) <= split_index:
		return
		
	var sector = sectors[split_index]
	sector.selecting = new_value

class Split:
	extends BindingSource

	signal notified(property: StringName)

	signal selecting_changed(new_value: bool)

	var selecting: bool = false:
		get:
			return selecting
		set(value):
			selecting = value
			selecting_changed.emit(value)

	func _init(split: Stoplight.Split):
		super(split, notified)

	func to_dict() -> Dictionary:
		return _source_object.to_dict()

	func from_dict(dict: Dictionary, container: Node):
		_source_object.from_dict(dict, container)

	func emit_all():
		for property_info in _property_list:
			var property = property_info['name']
			if property not in _source_object:
				continue

			notified.emit(property)
