class_name SimulatorVehicleCreator

const SPEED_FACTOR = 1000.0 / 3600.0

var _option_chooser: SimulatorRandomWeightedArray


func _init(rng: RandomNumberGenerator, parameters: Array[VehicleData.SpawnParameterData]):
	_option_chooser = SimulatorRandomWeightedArray.new(rng)

	for parameter in parameters:
		var option = RandomOption.new()
		_option_chooser.add_option(parameter.weight, option)

		option.length = parameter.length

		option.high_speed_acceleration_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.high_speed_acceleration_range, parameter.high_speed_acceleration_mean)

		option.high_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.high_speed_range, parameter.high_speed_mean)
		option.max_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.max_speed_range, parameter.max_speed_mean)

		option.zero_speed_distance_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.zero_speed_distance_range, parameter.zero_speed_distance_mean)
		option.half_speed_distance_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.half_speed_distance_range, parameter.half_speed_distance_mean)
		option.high_speed_distance_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.high_speed_distance_range, parameter.high_speed_distance_mean)


func create() -> SimulatorVehicleExtension:
	var vehicle = VehicleData.new()
	var option = _option_chooser.next() as RandomOption

	vehicle.length = option.length

	vehicle.high_speed_acceleration = option.high_speed_acceleration_rng.next()

	vehicle.high_speed = option.high_speed_rng.next() * SPEED_FACTOR
	vehicle.max_speed = option.max_speed_rng.next() * SPEED_FACTOR

	var distances = [
		option.zero_speed_distance_rng.next(),
		option.half_speed_distance_rng.next(),
		option.high_speed_distance_rng.next(),
	]
	distances.sort()

	vehicle.zero_speed_distance = distances[0]
	vehicle.half_speed_distance = distances[1]
	vehicle.high_speed_distance = distances[2]

	var vehicle_ext = SimulatorVehicleExtension.new(vehicle)
	return vehicle_ext


class RandomOption:
	var length: float

	var high_speed_acceleration_rng: SimulatorRandomNormalDistributionRange

	var high_speed_rng: SimulatorRandomNormalDistributionRange
	var max_speed_rng: SimulatorRandomNormalDistributionRange

	var zero_speed_distance_rng: SimulatorRandomNormalDistributionRange
	var half_speed_distance_rng: SimulatorRandomNormalDistributionRange
	var high_speed_distance_rng: SimulatorRandomNormalDistributionRange
