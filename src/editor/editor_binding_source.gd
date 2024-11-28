class_name EditorBindingSource
extends BindingSource


func _set(property, value):
	super(property, value)

	if not has_user_signal(property):
		return

	emit_signal(property)


func add_callback(property: StringName, callback: Callable):
	assert(property in _source_object)
	assert(callback.is_valid())

	if not has_user_signal(property):
		add_user_signal(property)

	connect(property, callback)


func remove_callback(property: StringName, callback: Callable):
	assert(property in _source_object)
	assert(callback.is_valid())

	disconnect(property, callback)

	if get_signal_connection_list(property).is_empty():
		remove_user_signal(property)


func _on_source_value_change_notified(source_property: StringName):
	super(source_property)

	if not has_user_signal(source_property):
		return

	emit_signal(source_property)
