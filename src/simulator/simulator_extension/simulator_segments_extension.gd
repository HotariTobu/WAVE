class_name SimulatorSegmentsExtension
extends SimulatorContentExtension

var length: float

var _vertex_exts: Array[SimulatorVertexExtension]


func _init(data: SegmentsData):
	super(data)


func extend(ext_of: Callable) -> void:
	super(ext_of)

	_assign_ext_array(&"_vertex_exts", &"vertex_ids", ext_of)

	var curve = Curve2D.new()

	for vertex_ext in _vertex_exts:
		curve.add_point(vertex_ext.pos)

	length = curve.get_baked_length()
