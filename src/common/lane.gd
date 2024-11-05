class_name Lane
extends Space

var speed_limit: int
var next_option_dict: Dictionary

func _ready():
	color = setting.lane_color
	width = setting.lane_width

func _to_string():
	return "Lane(Speed limit: %s, Next count: %s): %s" % [
		speed_limit,
		len(next_option_dict),
		super(),
	]

func to_dict() -> Dictionary:
	var next_option_dict_dict = {}

	for lane in next_option_dict:
		var lane_index = lane.get_index()

		var option = next_option_dict[lane]
		var option_dict = option.to_dict()

		next_option_dict_dict[lane_index] = option_dict

	return super().merged({
		'speed_limit': speed_limit,
		'next_option_dict_dict': next_option_dict_dict
	})

func from_dict(dict: Dictionary):
	super(dict)

	speed_limit = dict.get('speed_limit', NAN)

	var next_option_dict_dict = dict.get('next_option_dict_dict', {})

	next_option_dict = {}

	var container = get_parent()
	for lane_index in next_option_dict_dict:
		var option_dict = next_option_dict_dict[lane_index]

		var lane = container.get_child(lane_index)

		var option = Option.new()
		option.from_dict(option_dict)

		next_option_dict[lane] = option

class Option:
	var weight: float

	func _to_string():
		return "LaneOption(Weight: %s)" % [
			weight,
		]

	func to_dict() -> Dictionary:
		return {
			'weight': weight
		}

	func from_dict(dict: Dictionary):
		weight = dict.get('weight', NAN)
