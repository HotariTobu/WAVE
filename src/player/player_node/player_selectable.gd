class_name PlayerSelectable
extends Selectable

var _property_dict: Dictionary


func _init(property_dict: Dictionary):
	super(1)

	_property_dict = property_dict


func get_property_dict() -> Dictionary:
	return _property_dict
