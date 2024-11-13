class_name VertexData
extends ContentData

var x: float = NAN
var y: float = NAN


func to_vector() -> Vector2:
	return Vector2(x, y)


static func to_dict(data: ContentData) -> Dictionary:
	assert(data is VertexData)
	var dict = super(data)
	dict[&"x"] = data.x
	dict[&"y"] = data.y
	return dict


static func from_dict(dict: Dictionary, script: GDScript = VertexData) -> ContentData:
	var data = super(dict, script)
	assert(data is VertexData)
	data.x = dict.get(&"x", NAN)
	data.y = dict.get(&"y", NAN)
	return data
