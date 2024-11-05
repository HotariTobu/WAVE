class_name EditorLane
extends Lane

signal notified(property: StringName)

var selecting: bool = false:
	get:
		return selecting
	set(value):
		selecting = value
		_update_selecting()

func _init(use_collision: bool = true):
	speed_limit = 60
	next_option_dict = {}

	if use_collision:
		_setup_collision_shapes.call_deferred()

func from_dict(dict: Dictionary):
	super(dict)

	for lane in next_option_dict:
		var option = next_option_dict[lane]
		next_option_dict[lane] = Option.new(option)

func add_next_lane(lane: EditorLane):
	var option = Lane.Option.new()
	option.weight = 1
	next_option_dict[lane] = Option.new(option)
	notified.emit(&'next_option_dict')

func remove_next_lane(lane: EditorLane):
	next_option_dict.erase(lane)
	notified.emit(&'next_option_dict')

func _update_selecting():
	for child in get_children():
		var item = child as EditorSelectable
		item.selecting = selecting

func _setup_collision_shapes():
	var segments = EditorLaneSegments.new(self)
	add_child(segments)

	var last_point = EditorLanePoint.new(self, 0)
	add_child(last_point)

	for index in range(1, curve.point_count):
		var point = EditorLanePoint.new(self, index)
		add_child(point)

		segments.add_segment(last_point.position, point.position)
		last_point = point

class Option:
	extends BindingSource

	func _init(option: Lane.Option):
		super(option)

	func to_dict() -> Dictionary:
		return _source_object.to_dict()

	func from_dict(dict: Dictionary):
		_source_object.from_dict(dict)
