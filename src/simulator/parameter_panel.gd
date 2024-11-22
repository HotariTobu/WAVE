extends GridContainer

var parameter: ParameterData:
	get:
		return _parameter

var _parameter = ParameterData.new()

@onready var _source = BindingSource.new(_parameter)


func _ready():
	_parameter.step_delta = setting.default_step_delta
	_parameter.max_step = setting.default_max_step

	_parameter.vehicle_spawn_before_start = setting.default_vehicle_spawn_before_start
	_parameter.vehicle_spawn_after_start = setting.default_vehicle_spawn_after_start
	_parameter.vehicle_spawn_limit = setting.default_vehicle_spawn_limit

	_source.bind(&"step_delta").to($StepDeltaBox, &"value")
	_source.bind(&"max_step").to($MaxStepBox, &"value")

	_source.bind(&"vehicle_spawn_before_start").to_check_button($VehicleSpawnBeforeStartSwitch)
	_source.bind(&"vehicle_spawn_after_start").to_check_button($VehicleSpawnAfterStartSwitch)
	_source.bind(&"vehicle_spawn_limit").to($VehicleSpawnLimitBox, &"value")

	for child in get_children():
		if child is LineEdit:
			child.text_submitted.connect(child.release_focus.unbind(1))
