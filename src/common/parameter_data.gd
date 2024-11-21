class_name ParameterData

var step_delta: float
var max_step: int

static func to_dict(data: ParameterData) -> Dictionary:
	return {
		&"step_delta": data.step_delta,
		&"max_step": data.max_step,
	}


static func from_dict(dict: Dictionary) -> ParameterData:
	var data = ParameterData.new()
	data.step_delta = dict.get(&"step_delta", NAN)
	data.max_step = dict.get(&"max_step", NAN)
	return data
