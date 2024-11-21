extends GridContainer

var parameter: ParameterData:
	get:
		return _parameter

var _parameter = ParameterData.new()

@onready var _source = BindingSource.new(_parameter)


func _ready():	
	_parameter.step_delta = setting.default_step_delta
	_parameter.max_step = setting.default_max_step

	_source.bind(&"step_delta").to($StepDeltaBox, &"value")
	_source.bind(&"max_step").to($MaxStepBox, &"value")
