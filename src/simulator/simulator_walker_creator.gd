class_name SimulatorWalkerCreator

const SPEED_FACTOR = 1000.0 / 3600.0

var _option_chooser: SimulatorRandomWeightedArray


func _init(rng: RandomNumberGenerator, parameters: Array[WalkerData.SpawnParameterData]):
	_option_chooser = SimulatorRandomWeightedArray.new(rng)

	for parameter in parameters:
		var option = RandomOption.new()
		_option_chooser.add_option(parameter.weight, option)

		option.radius = parameter.radius

		option.speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.speed_range, parameter.speed_mean)
		option.overtake_speed_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.overtake_speed_range, parameter.overtake_speed_mean)

		option.personal_distance_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.personal_distance_range, parameter.personal_distance_mean)
		option.public_distance_rng = SimulatorRandomNormalDistributionRange.new(rng, parameter.public_distance_range, parameter.public_distance_mean)


func create() -> SimulatorWalkerExtension:
	var walker = WalkerData.new()
	var option = _option_chooser.next() as RandomOption

	walker.radius = option.radius

	walker.speed = option.speed_rng.next() * SPEED_FACTOR
	walker.overtake_speed = option.overtake_speed_rng.next() * SPEED_FACTOR

	var distances = [
		option.personal_distance_rng.next(),
		option.public_distance_rng.next(),
	]
	distances.sort()

	walker.personal_distance = distances[0]
	walker.public_distance = distances[1]

	var walker_ext = SimulatorWalkerExtension.new(walker)
	return walker_ext


class RandomOption:
	var radius: float

	var speed_rng: SimulatorRandomNormalDistributionRange
	var overtake_speed_rng: SimulatorRandomNormalDistributionRange

	var personal_distance_rng: SimulatorRandomNormalDistributionRange
	var public_distance_rng: SimulatorRandomNormalDistributionRange
