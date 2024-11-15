class_name Set

var _data: Dictionary


func add(value: Variant) -> void:
	_data[value] = null


func clear() -> void:
	_data.clear()


func duplicate(deep: bool = false) -> Set:
	var new_set = Set.new()
	new_set._data = _data.duplicate(deep)
	return new_set


func erase(value: Variant) -> bool:
	return _data.erase(value)


func has(value: Variant) -> bool:
	return _data.has(value)


func has_all(values: Array) -> bool:
	return _data.has_all(values)


func hash() -> int:
	return _data.hash()


func intersection(another: Set) -> Set:
	var new_set = Set.new()

	for value in _data:
		if value not in another._data:
			continue

		new_set._data[value] = null

	return new_set


func is_empty() -> bool:
	return _data.is_empty()


func is_read_only() -> bool:
	return _data.is_read_only()


func make_read_only() -> void:
	_data.make_read_only()


func merge(another: Set, overwrite: bool = false) -> void:
	_data.merge(another._data, overwrite)


func merged(another: Set, overwrite: bool = false) -> Set:
	var new_set = Set.new()
	new_set._data = _data.merged(another._data, overwrite)
	return new_set


func recursive_equal(another: Set, recursion_count: int) -> bool:
	var values = _data.keys()
	var another_values = another._data.keys()
	if values != another_values:
		return false

	if recursion_count == 0:
		return true

	for index in range(len(values)):
		var value = values[index]
		if value is Dictionary or value is Set:
			if not value.recursive_equal(another_values[index], recursion_count - 1):
				return false

	return true


func size() -> int:
	return _data.size()


func to_array() -> Array:
	return _data.keys()


static func from_array(values: Array) -> Set:
	var new_set = Set.new()
	for value in values:
		new_set._data[value] = null
	return new_set
