extends Node2D

static var agent_node_script_dict = {
	&"vehicles": PlayerVehicle,
}

@onready var _content_container = $ContentContainer
@onready var _agent_container = $AgentContainer


func _ready():
	player_global.source.add_callback(&"simulation", _renew_children)


func _renew_children():
	for child in _content_container.get_children():
		child.queue_free()

	for child in _agent_container.get_children():
		child.queue_free()

	for group_name in NetworkData.group_names:
		var script = PlayerScriptDict.node[group_name] as GDScript
		if script == null:
			continue

		var contents = player_global.simulation.network[group_name] as Array

		for content in contents:
			var node = script.new(content)
			_content_container.add_child(node)

	for group_name in agent_node_script_dict:
		var script = agent_node_script_dict[group_name] as GDScript
		var agents = player_global.simulation[group_name] as Array

		for agent in agents:
			var node = script.new(agent)
			_agent_container.add_child(node)


static func _static_init():
	agent_node_script_dict.make_read_only()
