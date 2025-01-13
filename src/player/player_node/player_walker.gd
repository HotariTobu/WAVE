class_name PlayerWalker
extends PlayerAgent

var _diameter: float


func _init(walker: WalkerData):
	super(walker)

	_collision_points = [Vector2.ZERO]
	_inactive_color = setting.walker_color
	_diameter = walker.radius * 2

	var forward = walker.pos_history[0] > walker.pos_history[1]
	var last_start_vertex_id: StringName
	var last_end_vertex_id: StringName

	var trail_length = 0.0
	var last_trail_length: float

	for index in range(len(walker.pos_history)):
		if walker.space_history.has(index):
			var bridge_ids = walker.space_history[index]
			last_trail_length = trail_length

			for bridge_id in bridge_ids:
				var bridge = player_global.content_db.player_data_of(bridge_id) as PlayerBridgeData

				if last_start_vertex_id == bridge.start_vertex_id:
					forward = true

				elif last_end_vertex_id == bridge.start_vertex_id:
					forward = true

				elif last_start_vertex_id == bridge.end_vertex_id:
					forward = false

				elif last_end_vertex_id == bridge.end_vertex_id:
					forward = false

				if forward:
					for point in bridge.points:
						_trail.add_point(point)
				else:
					for point in bridge.reversed_points:
						_trail.add_point(point)

				last_start_vertex_id = bridge.start_vertex_id
				last_end_vertex_id = bridge.end_vertex_id
				trail_length += bridge.length

		var pos = walker.pos_history[index]

		if forward:
			_offsets[index] = trail_length - pos
		else:
			_offsets[index] = last_trail_length + pos + _diameter

	_after_init()


func _draw():
	AgentHelper.draw_to(self, _diameter, setting.walker_head_length, _diameter, _get_color())
