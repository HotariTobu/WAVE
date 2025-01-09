class_name SimulatorRandomNormalDistributionRange

var _rng: RandomNumberGenerator

var _min_value: float
var _max_value: float

var _mean: float
var _deviation: float


func _init(rng: RandomNumberGenerator, range_value: FloatRange, mean: float):
	_rng = rng

	_min_value = range_value.begin
	_max_value = range_value.end

	_mean = mean
	_deviation = minf(abs(_min_value - mean), abs(_max_value - mean)) / 2


func next() -> float:
	var value = _rng.randfn(_mean, _deviation)
	return clampf(value, _min_value, _max_value)
