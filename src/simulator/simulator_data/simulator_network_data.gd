class_name SimulatorNetworkData

var lane_vertices: Array[SimulatorVertexData]
var lanes: Array[SimulatorLaneData]
var splits: Array[SimulatorSplitData]
var stoplights: Array[SimulatorStoplightData]
	
static var content_data_script_dict: Dictionary
	
static func _static_init():
	var network = SimulatorNetworkData.new()
	
	for group_name in NetworkData.group_names:
		var contents = network[group_name] as Array
		var script = contents.get_typed_script() as GDScript
		content_data_script_dict[group_name] = script
	
	content_data_script_dict.make_read_only()
	
func assign(network: NetworkData):
	var simulator_content_dict: Dictionary
	var group_name_dict: Dictionary

	for group_name in NetworkData.group_names:
		var contents = network[group_name]
		
		for content in contents:
			group_name_dict[content.id] = group_name

	group_name_dict.make_read_only()
	
	var data_of = simulator_data_of.bind(simulator_content_dict, group_name_dict)

	for group_name in NetworkData.group_names:
		var simulator_contents = self[group_name] as Array
		var contents = network[group_name] as Array
		
		for content in contents:
			var simulator_content = data_of.call(content.id) as SimulatorContentData
			simulator_content.assign(content, data_of)
			simulator_contents.append(simulator_content)
			
		simulator_contents.make_read_only()

static func simulator_data_of(content_id: StringName, simulator_content_dict: Dictionary, group_name_dict: Dictionary) -> SimulatorContentData:
	if simulator_content_dict.has(content_id):
		return simulator_content_dict[content_id]
	
	var group_name = group_name_dict[content_id]
	var script = content_data_script_dict[group_name] as GDScript
	var simulator_content = script.new()
	simulator_content_dict[content_id] = simulator_content
	return simulator_content
