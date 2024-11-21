class_name SimulatorVertexData
extends SimulatorContentData

var pos: Vector2


func assign(content: ContentData, data_of: Callable) -> void:
	super(content, data_of)
	var vertex = content as VertexData
	pos = vertex.pos
