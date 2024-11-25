class_name SimulatorVehicleCreator

const SPEED_FACTOR = 1000.0 / 3600.0

var _length_rng: SimulatorRandomWeightedArray

var _max_acceleration_rng: SimulatorRandomNormalDistributionRange

var _base_speed_rng: SimulatorRandomNormalDistributionRange
var _max_speed_rng: SimulatorRandomNormalDistributionRange

var _low_speed_distance_rng: SimulatorRandomNormalDistributionRange
var _high_speed_distance_rng: SimulatorRandomNormalDistributionRange


func _init(rng: RandomNumberGenerator, parameter: ParameterData):
	_length_rng = SimulatorRandomWeightedArray.new(rng, parameter.vehicle_length_options)

	_max_acceleration_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_max_acceleration_range, parameter.vehicle_max_acceleration_mean)

	_base_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_base_speed_range, parameter.vehicle_base_speed_mean)
	_max_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_max_speed_range, parameter.vehicle_max_speed_mean)

	_low_speed_distance_rng = SimulatorRandomNormalDistributionRange.new(
		rng, parameter.vehicle_low_speed_distance_range, parameter.vehicle_low_speed_distance_mean
	)
	_high_speed_distance_rng = SimulatorRandomNormalDistributionRange.new(
		rng, parameter.vehicle_high_speed_distance_range, parameter.vehicle_high_speed_distance_mean
	)


func create() -> SimulatorVehicleData:
	var vehicle = SimulatorVehicleData.new()

	vehicle.length = _length_rng.next()

	vehicle.max_acceleration = _max_acceleration_rng.next()

	vehicle.base_speed = _base_speed_rng.next() * SPEED_FACTOR
	vehicle.max_speed = _max_speed_rng.next() * SPEED_FACTOR

	vehicle.low_speed_distance = _low_speed_distance_rng.next()
	vehicle.high_speed_distance = _high_speed_distance_rng.next()

	vehicle.init_params()

	return vehicle
