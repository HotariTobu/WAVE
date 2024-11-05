class_name UnifyConverter
extends BindingConverter

var _first_object
var _property_name: StringName
var _fallback_value

func _init(first_object, property_name: StringName, fallback_value = null):
	_first_object = first_object
	_property_name = property_name
	_fallback_value = fallback_value

func source_to_target(source_value: Variant) -> Variant:
	var first_value = _first_object[_property_name]
	if source_value == first_value:
		return source_value
	
	return _fallback_value
