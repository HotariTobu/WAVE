class_name Stoplight
extends Spot

var offset: float
var splits: Array

func _ready():
	color = setting.stoplight_color
	radius = setting.stoplight_radius
	shape = setting.stoplight_shape

func _to_string():
	return "Stoplight(Offset: %s, Split count: %s): %s" % [
		offset,
		len(splits),
		super(),
	]

func to_dict() -> Dictionary:
	var split_to_dict = func(split):
		return split.to_dict()

	return super().merged({
		'offset': offset,
		'split_dicts': splits.map(split_to_dict)
	})

func from_dict(dict: Dictionary):
	super(dict)

	offset = dict.get('offset', NAN)

	var split_dicts = dict.get('split_dicts', [])
	var len_splits = len(split_dicts)

	splits = []
	splits.resize(len_splits)

	var container = get_parent()
	for index in range(len_splits):
		var split_dict = split_dicts[index]
		var split = Split.new()
		split.from_dict(split_dict, container)
		splits[index] = split

class Split:
	var duration: float
	var block_targets: Array[Space]

	func _to_string():
		return "StoplightSplit(Duration: %s)" % [
			duration,
		]

	func to_dict() -> Dictionary:
		var space_to_index = func(space: Space):
			return space.get_index()

		return {
			'duration': duration,
			'block_target_indices': block_targets.map(space_to_index)
		}

	func from_dict(dict: Dictionary, container: Node):
		duration = dict.get('duration', NAN)

		var block_target_indices = dict.get('block_target_indices', [])
		var len_block_targets = len(block_target_indices)

		block_targets = []
		block_targets.resize(len_block_targets)

		for index in range(len_block_targets):
			var space_index = block_target_indices[index]
			var space = container.get_child(space_index)
			block_targets[index] = space
			space.block_sources.append(self)
