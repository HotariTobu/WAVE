class_name SimulatorIterator
extends SimulatorPreparedData


func iterate(step: int):
	_iterate_vehicle_entry_point(step)

	_iterate_block_sources(step)
	_iterate_block_targets()

	_iterate_lanes(step)


func _iterate_vehicle_entry_point(step: int):
	for entry_point in vehicle_entry_points:
		if should_exit.call():
			return

		if step - entry_point.last_entry_step < entry_point.interval:
			continue

		if 0 <= entry_point.entry_lane.overflowing:
			continue

		if parameter.vehicle_spawn_rate <= rng.randf():
			continue

		var vehicle = vehicle_creator.create()
		var pos = entry_point.entry_lane.length
		vehicle.spawn_at(entry_point.entry_lane, pos, step)
		entry_point.entry_lane.update_overflowing()

		simulation.vehicles.append(vehicle)

		entry_point.last_entry_step = step


func _iterate_block_sources(step: int):
	var time = parameter.step_delta * step

	for block_source in block_sources:
		block_source.update_is_blocking(time)


func _iterate_block_targets():
	for block_target in block_targets:
		block_target.is_blocked = block_target.block_sources.any(_is_blocking)

	for lane in closable_lanes:
		lane.is_closed = lane.next_lanes.all(_is_blocked)


func _iterate_lanes(step: int):
	var loop_tail_buffer_dict: Dictionary

	for lane in ordered_lanes:
		if should_exit.call():
			return

		if lane.vehicles.is_empty():
			continue

		var rear_pos = lane.overflowed
		if lane.is_closed and rear_pos < 0:
			rear_pos = 0

		var removed_count = 0

		for vehicle in lane.vehicles:
			var pos = vehicle.pos_history[-1]

			var last_displacement = vehicle.over_last_pos - pos
			var last_speed = last_displacement * _inverted_step_delta
			var last_speed_rate = vehicle.get_speed_rate(last_speed)

			var actual_distance = pos - rear_pos
			var preferred_distance = vehicle.get_preferred_distance(last_speed_rate)
			var possible_displacement = maxf(0.0, actual_distance - preferred_distance)

			var preferred_speed = vehicle.get_preferred_speed(lane.speed_limit)
			var preferred_speed_rate = vehicle.get_speed_rate(preferred_speed)
			var acceleration = vehicle.max_acceleration * preferred_speed_rate
			var accelerated_speed = last_speed + acceleration * parameter.step_delta

			var speed = minf(preferred_speed, accelerated_speed)
			var preferred_displacement = speed * parameter.step_delta

			var next_displacement = minf(possible_displacement, preferred_displacement)
			var next_pos = pos - next_displacement

			vehicle.over_last_pos = pos
			vehicle.pos_history.append(next_pos)

			rear_pos = next_pos + vehicle.length

			if next_pos < 0:
				removed_count += 1

			#printt(
			#	"[%02d]" % (vehicle.spawn_step),
			#	"%.2f m" % (last_displacement),
			#	"%.2f km/h" % (last_speed * 3.6),
			#	"%.2f" % (last_speed_rate),
			#	"%.2f m" % (actual_distance),
			#	"%.2f m" % (preferred_distance),
			#	"%.2f km/h" % (preferred_speed * 3.6),
			#	"%.2f" % (preferred_speed_rate),
			#	"%.2f" % (acceleration),
			#	"%.2f km/h" % (accelerated_speed * 3.6),
			#	"%.2f km/h" % (speed * 3.6),
			#)

		for _i in range(removed_count):
			var vehicle = lane.vehicles.pop_front() as SimulatorVehicleData

			if lane.next_lane_chooser == null:
				vehicle.die(step)
				continue

			var next_lane = lane.next_lane_chooser.next() as SimulatorLaneData

			if lane.loop_next_lane_set.has(next_lane):
				var buffered_vehicles = loop_tail_buffer_dict.get_or_add(next_lane, []) as Array
				buffered_vehicles.append(vehicle)

				vehicle.pos_history[-1] += next_lane.length
				next_lane.update_overflowing_by(vehicle)

			else:
				vehicle.move_to(next_lane, step)
				next_lane.update_overflowing()

		lane.update_overflowing()

	for next_lane in loop_tail_buffer_dict:
		var buffered_vehicles = loop_tail_buffer_dict[next_lane]

		for vehicle in buffered_vehicles:
			vehicle.pos_history[-1] -= next_lane.length
			vehicle.move_to(next_lane, step)


static func _is_blocking(content: SimulatorContentData) -> bool:
	return content.is_blocking


static func _is_blocked(content: SimulatorContentData) -> bool:
	return content.is_blocked
