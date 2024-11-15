class_name EditorStoplightData
extends StoplightData

signal notified(property: StringName)


func add_split(split: SplitData):
	split_ids.append(split.id)
	notified.emit(&"split_ids")


func remove_split(split: SplitData):
	split_ids.erase(split.id)
	notified.emit(&"split_ids")


static func from_dict(dict: Dictionary, script: GDScript = EditorStoplightData) -> ContentData:
	return super(dict, script)
