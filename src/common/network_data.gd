class_name NetworkData

var lane_vertices: Array
var lanes: Array
var splits: Array
var stoplights: Array

static var content_data_script_dict = {
	&"lane_vertices": VertexData,
	&"lanes": LaneData,
	&"splits": SplitData,
	&"stoplights": StoplightData,
}

static var group_names: Array[StringName]:
	get:
		return Array(content_data_script_dict.keys(), TYPE_STRING_NAME, &"", null)


static func _static_init():
	content_data_script_dict.make_read_only()


static func to_dict(data: NetworkData) -> Dictionary:
	var dict: Dictionary
	dict[&"version"] = 0

	for group_name in content_data_script_dict:
		var script = content_data_script_dict[group_name]
		dict[group_name] = data[group_name].map(script.to_dict)

	return dict


static func from_dict(dict: Dictionary) -> NetworkData:
	var version = dict.get(&"version")

	var data = NetworkData.new()

	match version:
		0:
			for group_name in content_data_script_dict:
				var script = content_data_script_dict[group_name]
				data[group_name] = dict.get(group_name, []).map(script.from_dict)
		_:
			return null

	return data
