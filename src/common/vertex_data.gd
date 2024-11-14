class_name VertexData
extends ContentData

const NAN_POS = Vector2(NAN, NAN)

var pos: Vector2


static func pos_of(data: VertexData) -> Vector2:
	return data.pos


static func to_dict(data: ContentData) -> Dictionary:
	assert(data is VertexData)
	var dict = super(data)
	dict[&"pos"] = data.pos
	return dict


static func from_dict(dict: Dictionary, script: GDScript = VertexData) -> ContentData:
	var data = super(dict, script)
	assert(data is VertexData)
	data.pos = dict.get(&"pos", NAN_POS)
	return data
