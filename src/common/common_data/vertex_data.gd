class_name VertexData
extends ContentData

var pos: Vector2


static func pos_of(data: VertexData) -> Vector2:
	return data.pos


static func to_dict(data: ContentData) -> Dictionary:
	assert(data is VertexData)
	var dict = super(data)
	dict[&"pos"] = Pos.to_dict(data.pos)
	return dict


static func from_dict(dict: Dictionary, script: GDScript = VertexData) -> ContentData:
	var data = super(dict, script)
	assert(data is VertexData)
	data.pos = Pos.form_dict(dict.get(&"pos", {}))
	return data


static func new_default() -> ContentData:
	return from_dict({})


class Pos:
	static func to_dict(data: Vector2) -> Dictionary:
		return {
			&"x": data.x,
			&"y": data.y,
		}

	static func form_dict(dict: Dictionary) -> Vector2:
		return Vector2(dict.get(&"x", NAN), dict.get(&"y", NAN))
