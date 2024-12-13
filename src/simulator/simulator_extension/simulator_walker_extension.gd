class_name SimulatorWalkerExtension
extends SimulatorAgentExtension

var last_distance: float
var over_last_pos: float

var walker: WalkerData:
	get:
		return _data


func _init(data: WalkerData):
	super(data)
