class_name SimulationData

var parameter: ParameterData
var network: NetworkData

var block_history: Dictionary
var vehicles: Array[VehicleData]


static func to_dict(data: SimulationData) -> Dictionary:
	return {
		&"parameter": ParameterData.to_dict(data.parameter),
		&"network": NetworkData.to_dict(data.network),
		&"block_history": data.block_history,
		&"vehicles": data.vehicles.map(VehicleData.to_dict),
	}


static func from_dict(dict: Dictionary) -> SimulationData:
	var data = SimulationData.new()
	data.parameter = ParameterData.from_dict(dict.get(&"parameter", {}))
	data.network = NetworkData.from_dict(dict.get(&"network", {}))
	data.block_history = dict.get(&"block_history", {})
	data.vehicles.assign(dict.get(&"vehicles", []).map(VehicleData.from_dict))
	return data
