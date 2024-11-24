class_name SimulatorRandomWeightedArray

var _rng: RandomNumberGenerator

var _weights: PackedFloat32Array
var _values: Array


func _init(rng: RandomNumberGenerator, options: Array[ParameterData.RandomOption]):
	_rng = rng

	_weights = options.map(ParameterData.RandomOption.weight_of)
	_values = options.map(ParameterData.RandomOption.value_of)


func next() -> Variant:
	var index = _rng.rand_weighted(_weights)
	return _values[index]
