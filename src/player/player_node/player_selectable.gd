class_name PlayerSelectable
extends Selectable

var _propery_dict: Dictionary


func _init(property_dict: Dictionary):
	super(1)

	_propery_dict = property_dict


func get_property_dict() -> Dictionary:
	return _propery_dict
