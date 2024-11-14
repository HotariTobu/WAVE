class_name EditorLaneData
extends LaneData

signal notified(property: StringName)


func add_next(lane: LaneData, option: OptionData):
	next_option_dict[lane.id] = option
	notified.emit(&"next_option_dict")


func remove_next(lane: LaneData):
	next_option_dict.erase(lane.id)
	notified.emit(&"next_option_dict")


static func from_dict(dict: Dictionary, script: GDScript = EditorLaneData) -> ContentData:
	return super(dict, script)
