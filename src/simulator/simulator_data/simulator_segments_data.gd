class_name SimulatorSegmentsData
extends SimulatorContentData

var vertices: Array[SimulatorVertexData]

var curve = Curve2D.new()
var length: float


func assign(content: ContentData, data_of: Callable) -> void:
	super(content, data_of)
	var segments = content as SegmentsData
	assign_array(&"vertices", segments.vertex_ids, data_of)

	for vertex in vertices:
		curve.add_point(vertex.pos)
	length = curve.get_baked_length()
