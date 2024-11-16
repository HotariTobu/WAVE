class_name UnifyConverter
extends BindingConverter

var _base_value_getter: Callable
var _fallback_value


func _init(base_value_getter: Callable, fallback_value = null):
	_base_value_getter = base_value_getter
	_fallback_value = fallback_value


func source_to_target(source_value: Variant) -> Variant:
	var base_value = _base_value_getter.call()
	if source_value == base_value:
		return source_value

	return _fallback_value


static func from_property(object, property_name: StringName, fallback_value = null):
	var base_value_getter = func(): return object[property_name]
	return UnifyConverter.new(base_value_getter, fallback_value)
