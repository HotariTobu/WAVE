class_name BindingSourceProxy

var sources: Array[BindingSource]:
	get:
		return _sources

var _sources: Array[BindingSource]

var _proxy_dict: Dictionary
var _proxy_source_dict: Dictionary


func _init(sources_: Array[BindingSource]) -> void:
	_sources = sources_


func bind(source_property: StringName) -> Binder:
	return Binder.new(self, source_property)


func unbind(source_property: StringName) -> Unbinder:
	return Unbinder.new(self, source_property)


func bind_to(
	source_property: StringName,
	target_object,
	target_property: StringName,
	fallback_value: Variant = null,
	converter_pipeline: BindingConverterPipeline = null,
	target_value_change_signal = null
):
	var proxy_key = _get_proxy_key(source_property, target_object, target_property)

	var len_sources = len(_sources)
	var proxy = Proxy.new(len_sources, fallback_value)

	for index in range(len_sources):
		var source = _sources[index]

		var extended_converter_pipeline = converter_pipeline.copy()
		extended_converter_pipeline.append(ValueWrapper.converter.bind(index))

		source.bind_to(source_property, proxy, &"wrapper", extended_converter_pipeline, proxy.unified_value_changed)

	var proxy_source = BindingSource.new(proxy, proxy.notified)
	proxy_source.bind(&"unified_value").using(Proxy.revert_null).to(target_object, target_property, target_value_change_signal)

	_proxy_dict[proxy_key] = proxy
	_proxy_source_dict[proxy_key] = proxy_source


func unbind_from(source_property: StringName, target_object, target_property: StringName):
	var proxy_key = _get_proxy_key(source_property, target_object, target_property)

	var proxy = _proxy_dict[proxy_key]

	for source in _sources:
		source.unbind_from(source_property, proxy, &"wrapper")

	var proxy_source = _proxy_source_dict[proxy_key] as BindingSource
	proxy_source.unbind(&"unified_value").from(target_object, target_property)

	_proxy_dict.erase(proxy_key)
	_proxy_source_dict.erase(proxy_key)


static func _get_proxy_key(source_property: StringName, target_object, target_property: StringName):
	if target_object is Object:
		return "%s-%s.%s" % [source_property, target_object.get_instance_id(), target_property]

	if target_object is Dictionary:
		var id = target_object.get_or_add("__BINDING_ID__", UUID.v7())
		return "%s-%s.%s" % [source_property, id, target_property]

	push_error("The target object must be an object or a dict.")


class Binder:
	var _source: BindingSourceProxy
	var _source_property: StringName
	var _converter_pipeline: BindingConverterPipeline

	func _init(source: BindingSourceProxy, source_property: StringName, converter_pipeline: BindingConverterPipeline = null):
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

	func to(target_object, target_property: StringName, fallback_value: Variant = null, target_value_change_signal = null):
		_source.bind_to(_source_property, target_object, target_property, fallback_value, _converter_pipeline, target_value_change_signal)


class Unbinder:
	var _source: BindingSourceProxy
	var _source_property: StringName

	func _init(source: BindingSourceProxy, source_property: StringName):
		_source = source
		_source_property = source_property

	func from(target_object, target_property: StringName):
		_source.unbind_from(_source_property, target_object, target_property)


class Proxy:
	signal notified(property: StringName)
	signal unified_value_changed(new_unified_value: Variant)

	static var NULL = Object.new()

	var wrapper: ValueWrapper:
		get:
			return null
		set(new_wrapper):
			_values[new_wrapper.index] = new_wrapper.value
			notified.emit(&"unified_value")

	var unified_value: Variant:
		get:
			var first_value = _values.front()

			for value in _values:
				if first_value != value:
					return _fallback_value

			return first_value

		set(value):
			_values.fill(value)
			unified_value_changed.emit(value)

	var _values: Array
	var _fallback_value: Variant

	func _init(source_count: int, fallback_value) -> void:
		_values.resize(source_count)

		if fallback_value == null:
			_fallback_value = NULL
		else:
			_fallback_value = fallback_value

	static func revert_null(value):
		if typeof(value) == TYPE_OBJECT and value == NULL:
			return null

		return value


class ValueWrapper:
	var value: Variant
	var index: int

	static func converter(source_value: Variant, wrapper_index: int) -> ValueWrapper:
		var wrapper = ValueWrapper.new()
		wrapper.value = source_value
		wrapper.index = wrapper_index
		return wrapper
