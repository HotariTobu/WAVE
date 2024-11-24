class_name SimulatorVehicleCreator

const SPEED_FACTOR = 1000.0 / 3600.0

var _length_rng: SimulatorRandomWeightedArray

var _max_acceleration_rng: SimulatorRandomNormalDistributionRange

var _condition_speed_rng: SimulatorRandomNormalDistributionRange
var _relative_speed_rng: SimulatorRandomNormalDistributionRange
var _max_speed_rng: SimulatorRandomNormalDistributionRange

var _min_following_distance_rng: SimulatorRandomNormalDistributionRange
var _max_following_distance_rng: SimulatorRandomNormalDistributionRange


func _init(rng: RandomNumberGenerator, parameter: ParameterData):
	_length_rng = SimulatorRandomWeightedArray.new(rng, parameter.vehicle_length_options)

	_max_acceleration_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_max_acceleration_range, parameter.vehicle_max_acceleration_mean)
	
	_condition_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_condition_speed_range, parameter.vehicle_condition_speed_mean)
	_relative_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_relative_speed_range, parameter.vehicle_relative_speed_mean)
	_max_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.vehicle_max_speed_range, parameter.vehicle_max_speed_mean)

	_min_following_distance_rng = SimulatorRandomNormalDistributionRange.new(
		rng, parameter.vehicle_min_following_distance_range, parameter.vehicle_min_following_distance_mean
	)
	_max_following_distance_rng = SimulatorRandomNormalDistributionRange.new(
		rng, parameter.vehicle_max_following_distance_range, parameter.vehicle_max_following_distance_mean
	)


func create() -> SimulatorVehicleData:
	var vehicle = SimulatorVehicleData.new()

	vehicle.length = _length_rng.next()

	vehicle.max_acceleration = _max_acceleration_rng.next()
	
	vehicle.condition_speed = _condition_speed_rng.next() * SPEED_FACTOR
	vehicle.relative_speed = _relative_speed_rng.next() * SPEED_FACTOR
	vehicle.max_speed = _max_speed_rng.next() * SPEED_FACTOR

	vehicle.min_following_distance = _min_following_distance_rng.next()
	vehicle.max_following_distance = _max_following_distance_rng.next()

	vehicle.init_params()

	return vehicle
