class_name SimulatorWalkerExtension
extends SimulatorAgentExtension

var forward: bool
var over_last_pos: float

var diameter: float

var walker: WalkerData:
	get:
		return _data


func _init(data: WalkerData):
	super(data)

	diameter = data.radius * 2
