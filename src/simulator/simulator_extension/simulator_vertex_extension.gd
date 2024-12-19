class_name SimulatorVertexExtension
extends SimulatorContentExtension

var pos: Vector2:
	get:
		return _data.pos


func _init(data: VertexData):
	super(data)
