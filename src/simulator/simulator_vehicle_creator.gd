class_name SimulatorVehicleCreator

const SPEED_FACTOR = 1000.0 / 3600.0

var _length_rng: SimulatorRandomWeightedArray

var _high_speed_acceleration_rng: SimulatorRandomNormalDistributionRange

var _high_speed_rng: SimulatorRandomNormalDistributionRange
var _max_speed_rng: SimulatorRandomNormalDistributionRange

var _zero_speed_distance_rng: SimulatorRandomNormalDistributionRange
var _half_speed_distance_rng: SimulatorRandomNormalDistributionRange
var _high_speed_distance_rng: SimulatorRandomNormalDistributionRange


func _init(rng: RandomNumberGenerator, parameter: ParameterData):
	_length_rng = SimulatorRandomWeightedArray.new(rng)
	for o in parameter.vehicle_length_options:
		_length_rng.add_option(o.weight, o.value)

	_high_speed_acceleration_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_high_speed_acceleration_range, parameter.vehicle_high_speed_acceleration_mean)

	_high_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_high_speed_range, parameter.vehicle_high_speed_mean)
	_max_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_max_speed_range, parameter.vehicle_max_speed_mean)

	_zero_speed_distance_rng = SimulatorRandomNormalDistributionRange.new(
		rng, parameter.vehicle_zero_speed_distance_range, parameter.vehicle_zero_speed_distance_mean
	)
	_half_speed_distance_rng = SimulatorRandomNormalDistributionRange.new(
		rng, parameter.vehicle_half_speed_distance_range, parameter.vehicle_half_speed_distance_mean
	)
	_high_speed_distance_rng = SimulatorRandomNormalDistributionRange.new(
		rng, parameter.vehicle_high_speed_distance_range, parameter.vehicle_high_speed_distance_mean
	)


func create() -> SimulatorVehicleExtension:
	var vehicle = VehicleData.new()

	vehicle.length = _length_rng.next()

	vehicle.high_speed_acceleration = _high_speed_acceleration_rng.next()

	vehicle.high_speed = _high_speed_rng.next() * SPEED_FACTOR
	vehicle.max_speed = _max_speed_rng.next() * SPEED_FACTOR

	var distances = [
		_zero_speed_distance_rng.next(),
		_half_speed_distance_rng.next(),
		_high_speed_distance_rng.next(),
	]
	distances.sort()

	vehicle.zero_speed_distance = distances[0]
	vehicle.half_speed_distance = distances[1]
	vehicle.high_speed_distance = distances[2]

	var vehicle_ext = SimulatorVehicleExtension.new(vehicle)
	return vehicle_ext
