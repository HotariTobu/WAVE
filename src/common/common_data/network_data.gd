class_name NetworkData

var bridge_vertices: Array[VertexData]
var bridges: Array[BridgeData]
var lane_vertices: Array[VertexData]
var lanes: Array[LaneData]
var splits: Array[SplitData]
var stoplights: Array[StoplightData]

static var group_names: Array[StringName]
static var content_data_script_dict: Dictionary

static func _static_init():
	var network = NetworkData.new()

	var properties = network.get_property_list()
	for property in properties:
		var usage = property[&"usage"]
		if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue

		var name = property[&"name"]
		group_names.append(name)

	group_names.make_read_only()

	for group_name in group_names:
		var contents = network[group_name] as Array
		var script = contents.get_typed_script() as GDScript
		content_data_script_dict[group_name] = script

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
				data[group_name].assign(dict.get(group_name, []).map(script.from_dict))
		_:
			return null

	return data
