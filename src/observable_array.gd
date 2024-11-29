class_name ObservableArray

enum ReorderType { REVERSE, SHUFFLE, SORT }

signal value_inserted(added_value: Variant, position: int)
signal value_removed(removed_value: Variant, position: int)
signal duplicated
signal made_read_only
signal reordered(type: ReorderType)

var data: Array:
	get:
		return _data

var _data: Array


func all(method: Callable) -> bool:
	return _data.all(method)


func any(method: Callable) -> bool:
	return _data.any(method)


func append(value: Variant) -> void:
	var position = len(_data)
	_data.append(value)
	value_inserted.emit(value, position)


func append_array(array: Array) -> void:
	var old_size = len(_data)

	_data.append_array(array)

	for offset in range(len(array)):
		var position = old_size + offset
		var added_value = array[offset]
		value_inserted.emit(added_value, position)


func assign(array: Array) -> void:
	var clone = _data.duplicate()

	_data.assign(array)

	for position in range(len(clone)):
		var removed_value = clone[position]
		value_removed.emit(removed_value, position)

	for position in range(len(array)):
		var added_value = array[position]
		value_inserted.emit(added_value, position)


func back() -> Variant:
	return _data.back()


func bsearch(value: Variant, before: bool = true) -> int:
	return _data.bsearch(value, before)


func bsearch_custom(value: Variant, method: Callable, before: bool = true) -> int:
	return _data.bsearch_custom(value, method, before)


func clear() -> void:
	var clone = _data.duplicate()

	_data.clear()

	for position in range(len(clone)):
		var removed_value = clone[position]
		value_removed.emit(removed_value, position)


func count(value: Variant) -> int:
	return _data.count(value)


func duplicate(deep: bool = false) -> Array:
	var clone = _data.duplicate(deep)
	duplicated.emit()
	return clone


func erase(value: Variant) -> void:
	var position = _data.find(value)
	if position < 0:
		return

	_data.remove_at(position)
	value_removed.emit(value, position)


func fill(value: Variant) -> void:
	var positions = range(len(_data))
	var clone = _data.duplicate()

	_data.fill(value)

	for position in positions:
		var removed_value = clone[position]
		value_removed.emit(removed_value, position)

	for position in positions:
		value_inserted.emit(value, position)


func filter(method: Callable) -> Array:
	return _data.filter(method)


func find(what: Variant, from: int = 0) -> int:
	return _data.find(what, from)


func front() -> Variant:
	return _data.front()


func get_typed_builtin() -> int:
	return _data.get_typed_builtin()


func get_typed_class_name() -> StringName:
	return _data.get_typed_class_name()


func get_typed_script() -> Variant:
	return _data.get_typed_script()


func has(value: Variant) -> bool:
	return _data.has(value)


func hash() -> int:
	return _data.hash()


func insert(position: int, value: Variant) -> int:
	var error = _data.insert(position, value)
	if error == OK:
		value_inserted.emit(value, position)
	return error


func is_empty() -> bool:
	return _data.is_empty()


func is_read_only() -> bool:
	return _data.is_read_only()


func is_same_typed(array: Array) -> bool:
	return _data.is_same_typed(array)


func is_typed() -> bool:
	return _data.is_typed()


func make_read_only() -> void:
	_data.make_read_only()
	made_read_only.emit()


func map(method: Callable) -> Array:
	return _data.map(method)


func max() -> Variant:
	return _data.max()


func min() -> Variant:
	return _data.min()


func pick_random() -> Variant:
	return _data.pick_random()


func pop_at(position: int) -> Variant:
	var value = _data.pop_at(position)
	value_removed.emit(value, position)
	return value


func pop_back() -> Variant:
	var value = _data.pop_back()
	value_removed.emit(value, len(_data))
	return value


func pop_front() -> Variant:
	var value = _data.pop_front()
	value_removed.emit(value, 0)
	return value


func push_back(value: Variant) -> void:
	var position = len(_data)
	_data.push_back(value)
	value_inserted.emit(value, position)


func push_front(value: Variant) -> void:
	_data.push_front(value)
	value_inserted.emit(value, 0)


func reduce(method: Callable, accum: Variant = null) -> Variant:
	return _data.reduce(method, accum)


func remove_at(position: int) -> void:
	var value = _data[position]
	_data.remove_at(position)
	value_removed.emit(value, position)


func resize(new_size: int) -> int:
	var emitters: Array[Callable]
	var old_size = len(_data)

	if old_size < new_size:
		for position in range(old_size, new_size):
			var emitter = value_inserted.emit.bind(null, position)
			emitters.append(emitter)

	else:
		for position in range(new_size, old_size):
			var value = _data[position]
			var emitter = value_removed.emit.bind(value, position)
			emitters.append(emitter)

	var error = _data.resize(new_size)

	if error == OK:
		for emitter in emitters:
			emitter.call()

	return error


func reverse() -> void:
	_data.reverse()
	reordered.emit(ReorderType.REVERSE)


func rfind(what: Variant, from: int = -1) -> int:
	return _data.rfind(what, from)


func shuffle() -> void:
	_data.shuffle()
	reordered.emit(ReorderType.SHUFFLE)


func size() -> int:
	return _data.size()


func slice(begin: int, end: int, step: int, deep: bool = false) -> Array:
	return _data.slice(begin, end, step, deep)


func sort() -> void:
	_data.sort()
	reordered.emit(ReorderType.SORT)


func sort_custom(method: Callable) -> void:
	_data.sort_custom(method)
	reordered.emit(ReorderType.SORT)


static func from_array(array) -> ObservableArray:
	var observable_array = ObservableArray.new()
	observable_array._data = Array(array)
	return observable_array


static func from_base(base: Array, type: int, classname: StringName, script: Variant) -> ObservableArray:
	var observable_array = ObservableArray.new()
	observable_array._data = Array(base, type, classname, script)
	return observable_array
