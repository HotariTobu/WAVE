class_name SimulatorWalkerExtension
extends SimulatorAgentExtension

var forward: bool

var diameter: float

var walker: WalkerData:
	get:
		return _data


func _init(data: WalkerData):
	super(data)

	diameter = data.radius * 2
