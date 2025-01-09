class_name SimulatorRandomWeightedArray

var _rng: RandomNumberGenerator

var _weights: PackedFloat32Array
var _values: Array


func _init(rng: RandomNumberGenerator):
	_rng = rng


func add_option(weight: float, value: Variant) -> void:
	_weights.append(weight)
	_values.append(value)


func next() -> Variant:
	var index = _rng.rand_weighted(_weights)
	return _values[index]
