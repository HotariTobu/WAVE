class_name BindingSourceProxy

var _sources: Array[BindingSource]
var _proxy_dict: Dictionary

func _init(sources: Array[BindingSource]) -> void:
	_sources = sources

func bind(source_property: StringName) -> Binder:
	return Binder.new(self, source_property)


func unbind(source_property: StringName) -> Unbinder:
	return Unbinder.new(self, source_property)

func bind_to(
	source_property: StringName,
	target_object,
	target_property: StringName,
	fallback_value = null,
	converter_pipeline: BindingConverterPipeline = null,
	target_value_change_signal = null
):
	var proxy = Proxy


func unbind_from(source_property: StringName, target_object, target_property: StringName):
	breakpoint

class Binder:
	var _source: BindingSourceProxy
	var _source_property: StringName
	var _converter_pipeline: BindingConverterPipeline

	func _init(
		source: BindingSourceProxy,
		source_property: StringName,
		converter_pipeline: BindingConverterPipeline = null
	):
		_source = source
		_source_property = source_property

		if converter_pipeline == null:
			_converter_pipeline = BindingConverterPipeline.new()
		else:
			_converter_pipeline = converter_pipeline

	func using(converter) -> Binder:
		var converter_pipeline = _converter_pipeline.copy()
		converter_pipeline.append(converter)
		return Binder.new(_source, _source_property, converter_pipeline)

	func to(target_object, target_property: StringName, fallback_value = null, target_value_change_signal = null):
		_source.bind_to(
			_source_property,
			target_object,
			target_property,
			fallback_value,
			_converter_pipeline,
			target_value_change_signal
		)

class Unbinder:
	var _source: BindingSourceProxy
	var _source_property: StringName

	func _init(source: BindingSourceProxy, source_property: StringName):
		_source = source
		_source_property = source_property

	func from(target_object, target_property: StringName):
		_source.unbind_from(_source_property, target_object, target_property)

class Target:
	var _values: Array
	var _fallback_value: Variant

	func _init(source_count: int, fallback_value = null) -> void:
		_values.resize(source_count)
		_fallback_value = fallback_value

	func _set(property: StringName, value: Variant) -> bool:
		if property.is_valid_int():
			var index = int(property)
			_values[index] = value
			return true

		return false


	func _get(property: StringName) -> Variant:
		if property.is_valid_int():
			var index = int(property)
			var value = _values[index]
			if value == null:
				return 0

			return value

		return null

class ValueWrapper:
	var value: Variant
	var index: int
