class_name PlayerSegmentsData

var points: PackedVector2Array
var curve = Curve2D.new()
var length: float

func _init(segments: SegmentsData, data_of: Callable):
	var vertices = segments.vertex_ids.map(data_of)

	for vertex in vertices:
		points.append(vertex.pos)
		curve.add_point(vertex.pos)

	length = curve.get_baked_length()
