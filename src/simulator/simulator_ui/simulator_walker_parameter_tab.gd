extends Container

const SpawnParameterData = WalkerData.SpawnParameterData

var parameter: ParameterData:
	get:
		return parameter
	set(next):
		var prev = parameter
		if prev == next:
			return

		if prev != null:
			_unbind_cells(prev)

		if next != null:
			_bind_cells(next)

		parameter = next

var _source_dict: Dictionary

var _class_manager = BindingSource.new(ClassManager.new(), &"notified")


func _ready():
	_class_manager.bind(&"index").using(PlusOneConverter.new()).to(%ClassIndexBox, &"value", &"value_changed")
	_class_manager.bind(&"index").using(func(i): return i <= 0).to(%PrevButton, &"disabled")
	_class_manager.bind(&"index").using(func(i): return i >= _class_manager.count - 1).to(%NextButton, &"disabled")

	_class_manager.bind(&"parameter").to(%SpawnParameterPanel, &"parameter")

	_class_manager.bind(&"count").to(%ClassIndexBox, &"max_value")
	_class_manager.bind(&"count").using(func(c): return " / %s" % c).to(%ClassIndexBox, &"suffix")
	_class_manager.bind(&"count").using(func(c): return c <= 1).to(%RemoveButton, &"disabled")


func _bind_cells(next_parameter: ParameterData):
	var source = BindingSource.new(next_parameter)
	_source_dict[next_parameter] = source

	source.bind(&"walker_spawn_rate_before_start").to(%SpawnRateBeforeStartBox, &"value", &"value_changed")
	source.bind(&"walker_spawn_rate_after_start").to(%SpawnRateAfterStartBox, &"value", &"value_changed")

	source.bind(&"walker_spawn_parameters").to(_class_manager, &"parameters", _class_manager.parameters_changed)

	_class_manager.index = 0


func _unbind_cells(prev_parameter: ParameterData):
	var source = _source_dict[prev_parameter]
	_source_dict.erase(prev_parameter)

	source.unbind(&"walker_spawn_rate_before_start").from(%SpawnRateBeforeStartBox, &"value")
	source.unbind(&"walker_spawn_rate_after_start").from(%SpawnRateAfterStartBox, &"value")

	source.unbind(&"walker_spawn_parameters").from(_class_manager, &"parameters")


func _on_spawn_parameter_prev_button_pressed():
	_class_manager.index -= 1


func _on_spawn_parameter_next_button_pressed():
	_class_manager.index += 1


func _on_spawn_parameter_add_button_pressed():
	_class_manager.add_class.call()
	_class_manager.index += 1


func _on_spawn_parameter_remove_button_pressed():
	_class_manager.remove_class.call()
	if _class_manager.index > 0:
		_class_manager.index -= 1


class ClassManager:
	signal parameters_changed(new_parameters: Array[SpawnParameterData])
	signal notified(property: StringName)

	var parameters: Array[SpawnParameterData]:
		get:
			return parameters
		set(value):
			parameters = value
			notified.emit(&"parameter")
			notified.emit(&"count")

	var index: int:
		get:
			return index
		set(value):
			index = value
			notified.emit(&"parameter")

	var parameter: SpawnParameterData:
		get:
			if index < 0 or count <= index:
				# return null
				return SpawnParameterData.from_dict({})

			return parameters[index]

	var count: int:
		get:
			return len(parameters)

	func add_class():
		var parameter_dict = SpawnParameterData.to_dict(parameter)
		var new_parameter = SpawnParameterData.from_dict(parameter_dict)

		var new_parameters = parameters.duplicate()
		new_parameters.insert(index, new_parameter)
		parameters = new_parameters
		parameters_changed.emit(new_parameters)

	func remove_class():
		var new_parameters = parameters.duplicate()
		new_parameters.remove_at(index)
		parameters = new_parameters
		parameters_changed.emit(new_parameters)
