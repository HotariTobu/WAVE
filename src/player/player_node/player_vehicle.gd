class_name PlayerVehicle
extends PlayerAgent

var _length: float


func _init(vehicle: VehicleData):
	super(vehicle)

	_collision_points = [Vector2.ZERO, Vector2.LEFT * vehicle.length]
	_inactive_color = setting.vehicle_color
	_length = vehicle.length

	var trail_length = 0.0

	for index in range(len(vehicle.pos_history)):
		if vehicle.space_history.has(index):
			var lane_ids = vehicle.space_history[index]

			for lane_id in lane_ids:
				var lane = player_global.content_db.player_data_of(lane_id) as PlayerLaneData

				for point in lane.points:
					_trail.add_point(point)

				trail_length += lane.length

		var pos = vehicle.pos_history[index]
		_offsets[index] = trail_length - pos

	_after_init()


func _draw():
	AgentHelper.draw_to(self, setting.vehicle_width, setting.vehicle_head_length, _length, _get_color())
