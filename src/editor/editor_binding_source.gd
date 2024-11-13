class_name EditorBindingSource
extends BindingSource

var _callback_dict = {}


func add_callback(property: StringName, callback: Callable):
	if not _callback_dict.has(property):
		_callback_dict[property] = Set.new()
	var callback_set = _callback_dict[property] as Set

	assert(not callback_set.has(callback))

	callback_set.add(callback)


func remove_callback(property: StringName, callback: Callable):
	var callback_set = _callback_dict.get(property) as Set

	assert(callback_set != null)
	assert(callback_set.has(callback))

	callback_set.erase(callback)
	if callback_set.size() == 0:
		_callback_dict.erase(property)


func _set(property, value):
	super(property, value)

	if not _callback_dict.has(property):
		return

	var callback_set = _callback_dict[property] as Set
	for callback_value in callback_set.values():
		var callback = callback_value as Callable
		callback.call()
