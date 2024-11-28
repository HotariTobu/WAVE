class_name ObservableSet
extends Set

signal value_added(value: Variant)
signal value_removed(value: Variant)
signal duplicated
signal made_read_only


func add(value: Variant) -> bool:
	if super(value):
		value_added.emit(value)
		return true

	return false


func add_all(values: Array) -> void:
	super(values)

	for value in values:
		value_added.emit(value)


func clear() -> void:
	var values = _data.keys()

	super()

	for value in values:
		value_removed.emit(value)


func duplicate(deep: bool = false) -> Set:
	var new_set = super(deep)
	duplicated.emit()
	return new_set


func erase(value: Variant) -> bool:
	if super(value):
		value_removed.emit(value)
		return true

	return false


func intersect(another: Set) -> void:
	for value in another._data:
		if _data.has(value):
			continue

		_data.erase(value)
		value_removed.emit(value)


func make_read_only() -> void:
	super()
	made_read_only.emit()


func merge(another: Set) -> void:
	for value in another._data:
		if _data.has(value):
			continue

		_data[value] = null
		value_added.emit(value)


static func from_array(values: Array) -> Set:
	var new_set = ObservableSet.new()
	for value in values:
		new_set._data[value] = null
	return new_set
