extends Container

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


func _bind_cells(next_parameter: ParameterData):
	var source = BindingSource.new(next_parameter)
	_source_dict[next_parameter] = source

	source.bind(&"step_delta").to(%StepDeltaBox, &"value", &"value_changed")
	source.bind(&"max_step").to(%MaxStepBox, &"value", &"value_changed")
	source.bind(&"max_entry_step_gap").to(%MaxEntryStepGapBox, &"value", &"value_changed")
	source.bind(&"random_seed").to(%RandomSeed, &"value", &"value_changed")


func _unbind_cells(prev_parameter: ParameterData):
	var source = _source_dict[prev_parameter]
	_source_dict.erase(prev_parameter)

	source.unbind(&"step_delta").from(%StepDeltaBox, &"value")
	source.unbind(&"max_step").from(%MaxStepBox, &"value")
	source.unbind(&"max_entry_step_gap").from(%MaxEntryStepGapBox, &"value")
	source.unbind(&"random_seed").from(%RandomSeed, &"value")
