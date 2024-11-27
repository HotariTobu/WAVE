class_name EditorContentConstraint

signal died
signal revived

signal action_requested(action: Callable)

var dead: bool = false:
	get:
		return dead
	set(next):
		var prev = dead
		if prev == next:
			return

		dead = next

		if next:
			died.emit()
		else:
			revived.emit()

var data: ContentData:
	get:
		return _data

var copy_dependency_id_set: Set:
	get:
		var id_set = Set.new()

		for copy_dependency_getter in _copy_dependency_getters:
			id_set.merge(copy_dependency_getter.call())

		return id_set

var _data: ContentData
var _data_source: EditorBindingSource

var _targets: Array
var _snapshots: Array

var _copy_dependency_getters: Array[Callable]


func _init(content: ContentData):
	_data = content
	_data_source = editor_global.source_db.get_or_add(content)

	_constrain.call_deferred()


func _constrain():
	pass


func bind_array(self_content_property: StringName, constraint_property: StringName):
	assert(_data[self_content_property] is Array)

	var target = ArrayTarget.new()
	target.value_added.connect(_add_self_data_to_constraint_of.bind(constraint_property))
	target.value_removed.connect(_erase_self_data_from_constraint_of.bind(constraint_property))
	_data_source.bind(self_content_property).to(target, &"values")
	_targets.append(target)

	died.connect(func(): _erase_all_self_data_from_constraint_of(_data[self_content_property], constraint_property))
	revived.connect(func(): _add_all_self_data_to_constraint_of(_data[self_content_property], constraint_property))


func bind_dict(self_content_property: StringName, constraint_property: StringName):
	assert(_data[self_content_property] is Dictionary)

	var target = DictionaryTarget.new()
	target.key_added.connect(_add_self_data_to_constraint_of.bind(constraint_property))
	target.key_removed.connect(_erase_self_data_from_constraint_of.bind(constraint_property))
	_data_source.bind(self_content_property).to(target, &"keys")
	_targets.append(target)

	died.connect(func(): _erase_all_self_data_from_constraint_of(_data[self_content_property].keys(), constraint_property))
	revived.connect(func(): _add_all_self_data_to_constraint_of(_data[self_content_property].keys(), constraint_property))


func unlink_array_on_died(content_set: Set, content_property: StringName):
	var snapshot_index = _get_next_snapshot_index()
	died.connect(func(): _take_unlink_array_snapshot(content_set, content_property, snapshot_index))
	revived.connect(func(): _restore_unlink_array_snapshot(content_property, snapshot_index))


func unlink_dict_on_died(content_set: Set, content_property: StringName):
	var snapshot_index = _get_next_snapshot_index()
	died.connect(func(): _take_unlink_dict_snapshot(content_set, content_property, snapshot_index))
	revived.connect(func(): _restore_unlink_dict_snapshot(content_property, snapshot_index))


func _include_array_on_copy(content_property: StringName):
	assert(content_property in _data)
	assert(_data[content_property] is Array)

	var copy_dependency_getter = func(): return Set.from_array(_data[content_property])
	_copy_dependency_getters.append(copy_dependency_getter)


func _include_dict_on_copy(content_property: StringName):
	assert(content_property in _data)
	assert(_data[content_property] is Dictionary)

	var copy_dependency_getter = func(): return Set.from_array(_data[content_property].keys())
	_copy_dependency_getters.append(copy_dependency_getter)


func _include_set_on_copy(constraint_property: StringName):
	assert(constraint_property in self)
	assert(self[constraint_property] is Set)

	_copy_dependency_getters.append(_get_set_copy_dependency.bind(constraint_property))


func _add_self_data_to_constraint_of(content_id: StringName, constraint_property: StringName):
	var constraint = editor_global.constraint_db.of(content_id)

	assert(constraint[constraint_property] is Set)

	constraint[constraint_property].add(_data)


func _erase_self_data_from_constraint_of(content_id: StringName, constraint_property: StringName):
	var constraint = editor_global.constraint_db.of(content_id)

	assert(constraint[constraint_property] is Set)

	constraint[constraint_property].erase(_data)


func _add_all_self_data_to_constraint_of(content_ids: Array, constraint_property: StringName):
	for content_id in content_ids:
		_add_self_data_to_constraint_of(content_id, constraint_property)


func _erase_all_self_data_from_constraint_of(content_ids: Array, constraint_property: StringName):
	for content_id in content_ids:
		_erase_self_data_from_constraint_of(content_id, constraint_property)


func _get_next_snapshot_index():
	var snapshot_index = len(_snapshots)
	_snapshots.append(null)
	return snapshot_index


func _take_unlink_array_snapshot(content_set: Set, content_property: StringName, snapshot_index: int):
	var content_dead_index_dict: Dictionary

	for content in content_set.to_array():
		assert(content[content_property] is Array)

		var index = content[content_property].find(_data.id)
		content_dead_index_dict[content] = index

		var new_array = content[content_property].duplicate()
		new_array.remove_at(index)

		var source = editor_global.source_db.get_or_add(content)
		var action = func(): source[content_property] = new_array
		action_requested.emit(action)

	_snapshots[snapshot_index] = content_dead_index_dict


func _restore_unlink_array_snapshot(content_property: StringName, snapshot_index: int):
	var content_dead_index_dict = _snapshots[snapshot_index] as Dictionary

	for content in content_dead_index_dict:
		assert(content[content_property] is Array)

		var index = content_dead_index_dict[content]

		var new_array = content[content_property].duplicate()
		new_array.insert(index, _data.id)

		var source = editor_global.source_db.get_or_add(content)
		var action = func(): source[content_property] = new_array
		action_requested.emit(action)

	_snapshots[snapshot_index] = null


func _take_unlink_dict_snapshot(content_set: Set, content_property: StringName, snapshot_index: int):
	var content_removed_value_dict: Dictionary

	for content in content_set.to_array():
		assert(content[content_property] is Dictionary)

		var value = content[content_property][_data.id]
		content_removed_value_dict[content] = value

		var new_dict = content[content_property].duplicate()
		new_dict.erase(_data.id)

		var source = editor_global.source_db.get_or_add(content)
		var action = func(): source[content_property] = new_dict
		action_requested.emit(action)

	_snapshots[snapshot_index] = content_removed_value_dict


func _restore_unlink_dict_snapshot(content_property: StringName, snapshot_index: int):
	var content_removed_value_dict = _snapshots[snapshot_index] as Dictionary

	for content in content_removed_value_dict:
		assert(content[content_property] is Dictionary)

		var value = content_removed_value_dict[content]

		var new_dict = content[content_property].duplicate()
		new_dict[_data.id] = value

		var source = editor_global.source_db.get_or_add(content)
		var action = func(): source[content_property] = new_dict
		action_requested.emit(action)

	_snapshots[snapshot_index] = null


func _get_set_copy_dependency(constraint_property: StringName):
	var sub_copy_dependency_id_set = Set.new()

	for content in self[constraint_property].to_array():
		sub_copy_dependency_id_set.add(content.id)

		var constraint = editor_global.constraint_db.of(content.id)
		sub_copy_dependency_id_set.merge(constraint.copy_dependency_id_set)

	return sub_copy_dependency_id_set


class ArrayTarget:
	signal value_added(value: Variant)
	signal value_removed(value: Variant)

	var values: Array:
		get:
			return values
		set(next):
			var prev = values
			emit_diff(prev, next)
			values = next

	func emit_diff(prev: Array, next: Array):
		var prev_set = Set.from_array(prev)

		for value in next:
			if prev_set.has(value):
				prev_set.erase(value)
			else:
				value_added.emit(value)

		for value in prev_set.to_array():
			value_removed.emit(value)


class DictionaryTarget:
	signal key_added(key: Variant)
	signal key_removed(key: Variant)

	var keys: Dictionary:
		get:
			return keys
		set(next):
			var prev = keys
			emit_diff(prev, next)
			keys = next

	func emit_diff(prev: Dictionary, next: Dictionary):
		var prev_set = Set.from_array(prev.keys())

		for key in next:
			if prev_set.has(key):
				prev_set.erase(key)
			else:
				key_added.emit(key)

		for key in prev_set.to_array():
			key_removed.emit(key)
