class_name SimulatorVehicleCreator

const SPEED_FACTOR = 1000.0 / 3600.0

var _length_rng: WeightedArrayRandom

var _relative_speed_rng: NormalDistributionRangeRandom
var _max_speed_rng: NormalDistributionRangeRandom

var _min_following_distance_rng: NormalDistributionRangeRandom
var _max_following_distance_rng: NormalDistributionRangeRandom


func _init(rng: RandomNumberGenerator, parameter: ParameterData):
	_length_rng = WeightedArrayRandom.new(rng, parameter.vehicle_length_options)

	_relative_speed_rng = NormalDistributionRangeRandom.new(rng, parameter.vehicle_relative_speed_range, parameter.vehicle_relative_speed_mean)
	_max_speed_rng = NormalDistributionRangeRandom.new(rng, parameter.vehicle_max_speed_range, parameter.vehicle_max_speed_mean)

	_min_following_distance_rng = NormalDistributionRangeRandom.new(rng, parameter.vehicle_min_following_distance_range, parameter.vehicle_min_following_distance_mean)
	_max_following_distance_rng = NormalDistributionRangeRandom.new(rng, parameter.vehicle_max_following_distance_range, parameter.vehicle_max_following_distance_mean)


func create() -> VehicleData:
	var vehicle = VehicleData.new()

	vehicle.length = _length_rng.next()

	vehicle.relative_speed = _relative_speed_rng.next() * SPEED_FACTOR
	vehicle.max_speed = _max_speed_rng.next() * SPEED_FACTOR

	vehicle.min_following_distance = _min_following_distance_rng.next()
	vehicle.max_following_distance = _max_following_distance_rng.next()

	return vehicle


class WeightedArrayRandom:
	var _rng: RandomNumberGenerator

	var _weights: PackedFloat32Array
	var _values: PackedFloat32Array

	func _init(rng: RandomNumberGenerator, options: Array[ParameterData.RandomOption]):
		_rng = rng

		var weights = options.map(ParameterData.RandomOption.weight_of)
		var values = options.map(ParameterData.RandomOption.value_of)
		_weights = PackedFloat32Array(weights)
		_values = PackedFloat32Array(values)

	func next() -> float:
		var index = _rng.rand_weighted(_weights)
		return _values[index]


class NormalDistributionRangeRandom:
	var _rng: RandomNumberGenerator

	var _min_value: float
	var _max_value: float

	var _mean: float
	var _deviation: float

	func _init(rng: RandomNumberGenerator, range_value: ParameterData.IntRange, mean: int):
		_rng = rng

		_min_value = range_value.begin
		_max_value = range_value.end

		_mean = mean
		_deviation = minf(abs(_min_value - mean), abs(_max_value - mean))

	func next() -> float:
		var value = _rng.randfn(_mean, _deviation)
		return clampf(value, _min_value, _max_value)
