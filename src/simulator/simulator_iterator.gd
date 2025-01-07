class_name SimulatorIterator
extends SimulatorPreparedData


func iterate(step: int) -> bool:
	if _done(step):
		return false

	_iterate_walker_entry_point(step)
	_iterate_vehicle_entry_point(step)

	_iterate_block_sources(step)
	_iterate_block_targets(step)

	_iterate_forward_bridges(step)
	_iterate_backward_bridges(step)
	_iterate_lanes(step)

	return true


func _done(step: int) -> bool:
	return _parameter.max_step <= step


func _iterate_walker_entry_point(step: int):
	for entry_point in _walker_entry_points:
		if _should_exit.call():
			return

		if step < entry_point.next_entry_step:
			continue

		var bridge_ext = entry_point.entry_space_ext as SimulatorBridgeExtension

		# if 0 <= bridge_ext.overflowing:
		# 	continue

		if _rng.randf() >= _parameter.walker_spawn_rate:
			continue

		var walker_ext = _walker_creator.create()
		walker_ext.forward = bridge_ext.prev_bridge_exts.is_empty()
		var pos = bridge_ext.length if walker_ext.forward else 0.0
		walker_ext.spawn_at(bridge_ext, pos, step)
		simulation.walkers.append(walker_ext.walker)

		# if walker_ext.forward:
		# 	bridge_ext.forward_arrange_walker_exts_from_end()
		# else:
		# 	bridge_ext.backward_arrange_walker_exts_from_start()

		# bridge_ext.update_overflowing()
		entry_point.next_entry_step = step + entry_point.interval


func _iterate_vehicle_entry_point(step: int):
	for entry_point in _vehicle_entry_points:
		if _should_exit.call():
			return

		if step < entry_point.next_entry_step:
			continue

		var lane_ext = entry_point.entry_space_ext as SimulatorLaneExtension

		if 0 <= lane_ext.overflowing:
			continue

		if _rng.randf() >= _parameter.vehicle_spawn_rate:
			continue

		var vehicle_ext = _vehicle_creator.create()
		var pos = lane_ext.length
		vehicle_ext.spawn_at(lane_ext, pos, step)
		simulation.vehicles.append(vehicle_ext.vehicle)

		lane_ext.update_overflowing()
		entry_point.next_entry_step = step + entry_point.interval


func _iterate_block_sources(step: int):
	if _should_exit.call():
		return

	var time = _parameter.step_delta * step

	for block_source_ext in _block_source_exts:
		block_source_ext.update_is_blocking(time)


func _iterate_block_targets(step: int):
	if _should_exit.call():
		return

	for block_target_ext in _block_target_exts:
		block_target_ext.is_blocked = block_target_ext.block_source_exts.any(_is_blocking)

		if not block_target_ext.is_blocked:
			continue

		simulation.block_history[block_target_ext.id].append(step)

	for bridge_ext in _closable_bridge_exts:
		bridge_ext.forward_is_closed = bridge_ext.next_bridge_exts.all(_is_blocked)
		bridge_ext.backward_is_closed = bridge_ext.prev_bridge_exts.all(_is_blocked)

	for lane_ext in _closable_lane_exts:
		lane_ext.is_closed = lane_ext.next_lane_exts.all(_is_blocked)


func _iterate_forward_bridges(step: int):
	var loop_tail_buffer_dict: Dictionary

	for bridge_ext in _forward_ordered_bridge_exts:
		if _should_exit.call():
			return

		if bridge_ext.agent_exts.is_empty():
			continue

		var next_crowd_tail = -INF
		if bridge_ext.forward_is_closed:
			next_crowd_tail = 0.0

		var walker_count = len(bridge_ext.agent_exts)
		var removed_count = 0

		for index in range(walker_count):
			var walker_ext = bridge_ext.agent_exts[index] as SimulatorWalkerExtension
			var walker = walker_ext.walker

			var pos = walker.pos_history[-1]
			var tail = pos + walker_ext.diameter

			var crowd_tail = next_crowd_tail

			var tails = bridge_ext.tails_array[index]
			if bridge_ext.width_limit <= len(tails):
				next_crowd_tail = tail

			if not walker_ext.forward:
				continue

			var preferred_displacement = walker.speed * _parameter.step_delta

			var last_displacement = walker_ext.over_last_pos - pos
			var preferred_distance = (walker.public_distance - walker.personal_distance) * last_displacement / preferred_displacement + walker.personal_distance
			var affected_pos = crowd_tail + preferred_distance
			var affected_displacement = maxf(0.0, pos - affected_pos)

			var next_displacement = min(preferred_displacement, affected_displacement)
			var next_pos = pos - next_displacement

			walker_ext.over_last_pos = pos
			walker.pos_history.append(next_pos)

			bridge_ext.forward_arrange_walker_exts_from(index)

			if next_pos < 0:
				removed_count += 1

		for _i in range(removed_count):
			var walker_ext = bridge_ext.agent_exts.pop_front() as SimulatorWalkerExtension

			if bridge_ext.choose_next_bridge_ext == null:
				walker_ext.die(step)
				continue

			var next_bridge_ext = bridge_ext.choose_next_bridge_ext.call() as SimulatorBridgeExtension

			if bridge_ext.loop_next_bridge_ext_set.has(next_bridge_ext):
				var buffered_walker_exts = loop_tail_buffer_dict.get_or_add(next_bridge_ext, []) as Array
				buffered_walker_exts.append(walker_ext)

				var walker = walker_ext.walker
				walker.pos_history[-1] += next_bridge_ext.length

			else:
				walker_ext.move_to(next_bridge_ext, step)
				# next_bridge_ext.forward_arrange_walker_exts_from_end()

		# bridge_ext.forward_remove_tails(removed_count)

	for next_bridge_ext in loop_tail_buffer_dict:
		var buffered_walker_exts = loop_tail_buffer_dict[next_bridge_ext]

		for walker_ext in buffered_walker_exts:
			walker_ext.walker.pos_history[-1] -= next_bridge_ext.length
			walker_ext.move_to(next_bridge_ext, step)
			# next_bridge_ext.forward_arrange_walker_exts_from_end()


func _iterate_backward_bridges(step: int):
	var loop_tail_buffer_dict: Dictionary

	for bridge_ext in _backward_ordered_bridge_exts:
		if _should_exit.call():
			return

		if bridge_ext.agent_exts.is_empty():
			continue

		var next_crowd_head = INF
		if bridge_ext.backward_is_closed:
			next_crowd_head = bridge_ext.length

		var walker_count = len(bridge_ext.agent_exts)
		var removed_count = 0

		for index in range(walker_count - 1, -1, -1):
			var walker_ext = bridge_ext.agent_exts[index] as SimulatorWalkerExtension
			var walker = walker_ext.walker

			var pos = walker.pos_history[-1]

			var crowd_head = next_crowd_head

			var tails = bridge_ext.tails_array[index]
			if bridge_ext.width_limit <= len(tails):
				next_crowd_head = pos

			if walker_ext.forward:
				continue

			var preferred_displacement = walker.speed * _parameter.step_delta

			var last_displacement = pos - walker_ext.over_last_pos
			var preferred_distance = (walker.public_distance - walker.personal_distance) * last_displacement / preferred_displacement + walker.personal_distance
			var affected_pos = crowd_head - preferred_distance
			var affected_displacement = maxf(0.0, affected_pos - pos)

			var next_displacement = min(preferred_displacement, affected_displacement)
			var next_pos = pos + next_displacement

			walker_ext.over_last_pos = pos
			walker.pos_history.append(next_pos)

			bridge_ext.backward_arrange_walker_exts_from(index)

			if next_pos > bridge_ext.length:
				removed_count += 1

		for _i in range(removed_count):
			var walker_ext = bridge_ext.agent_exts.pop_back() as SimulatorWalkerExtension

			if bridge_ext.choose_prev_bridge_ext == null:
				walker_ext.die(step)
				continue

			var prev_bridge_ext = bridge_ext.choose_prev_bridge_ext.call() as SimulatorBridgeExtension

			if bridge_ext.loop_prev_bridge_ext_set.has(prev_bridge_ext):
				var buffered_walker_exts = loop_tail_buffer_dict.get_or_add(prev_bridge_ext, []) as Array
				buffered_walker_exts.append(walker_ext)

				var walker = walker_ext.walker
				walker.pos_history[-1] += prev_bridge_ext.length

			else:
				walker_ext.move_to(prev_bridge_ext, step)
				# prev_bridge_ext.backward_arrange_walker_exts_from_start()

		# bridge_ext.backward_remove_tails(removed_count)

	for prev_bridge_ext in loop_tail_buffer_dict:
		var buffered_walker_exts = loop_tail_buffer_dict[prev_bridge_ext]

		for walker_ext in buffered_walker_exts:
			walker_ext.walker.pos_history[-1] -= prev_bridge_ext.length
			walker_ext.move_to(prev_bridge_ext, step)
			# prev_bridge_ext.backward_arrange_walker_exts_from_start()


func _iterate_lanes(step: int):
	var loop_tail_buffer_dict: Dictionary

	for lane_ext in _ordered_lane_exts:
		if _should_exit.call():
			return

		if lane_ext.agent_exts.is_empty():
			continue

		var rear_pos = lane_ext.overflowed
		if lane_ext.is_closed and rear_pos < 0:
			rear_pos = 0

		var removed_count = 0

		for agent_ext in lane_ext.agent_exts:
			var vehicle_ext = agent_ext as SimulatorVehicleExtension
			var vehicle = vehicle_ext.vehicle

			var pos = vehicle.pos_history[-1]

			var actual_distance = pos - rear_pos
			var possible_displacement = maxf(0.0, actual_distance - vehicle.zero_speed_distance)

			var last_displacement = vehicle_ext.over_last_pos - pos
			var last_speed = last_displacement * _inverted_step_delta

			var preferred_distance = vehicle_ext.get_preferred_distance(last_speed)
			var preferred_displacement = actual_distance - preferred_distance
			var relative_displacement = actual_distance - vehicle_ext.last_distance
			var affected_displacement = maxf(preferred_displacement, -relative_displacement)
			var decelerated_displacement = maxf(0.0, (preferred_displacement + affected_displacement) / 2)

			var preferred_speed = vehicle_ext.get_preferred_speed(lane_ext.speed_limit)
			var acceleration = vehicle_ext.get_acceleration(preferred_speed)
			var accelerated_speed = last_speed + acceleration * _parameter.step_delta
			var speed = min(vehicle.max_speed, preferred_speed, accelerated_speed)
			var accelerated_displacement = speed * _parameter.step_delta

			var next_displacement = min(possible_displacement, decelerated_displacement, accelerated_displacement)
			var next_pos = pos - next_displacement

			vehicle_ext.last_distance = actual_distance
			vehicle_ext.over_last_pos = pos
			vehicle.pos_history.append(next_pos)

			rear_pos = next_pos + vehicle.length

			if next_pos < 0:
				removed_count += 1

			#printt(
			#	#"[%02d]" % (vehicle.spawn_step),
			#	"[%02d]" % (vehicle.length),
			#	"%.2f m" % (last_displacement),
			#	"%.2f km/h" % (last_speed * 3.6),
			#	"%.2f m" % (actual_distance),
			#	"%.2f m" % (preferred_distance),
			#	"%.2f km/h" % (relative_speed * 3.6),
			#	"%.2f km/h" % (preferred_speed * 3.6),
			#	"%.2f" % (acceleration),
			#	"%.2f km/h" % (accelerated_speed * 3.6),
			#	"%.2f km/h" % (speed * 3.6),
			#)

		for _i in range(removed_count):
			var vehicle_ext = lane_ext.agent_exts.pop_front() as SimulatorVehicleExtension

			if lane_ext.choose_next_lane_ext == null:
				vehicle_ext.die(step)
				continue

			var next_lane_ext = lane_ext.choose_next_lane_ext.call() as SimulatorLaneExtension

			if lane_ext.loop_next_lane_ext_set.has(next_lane_ext):
				var buffered_vehicle_exts = loop_tail_buffer_dict.get_or_add(next_lane_ext, []) as Array
				buffered_vehicle_exts.append(vehicle_ext)

				var vehicle = vehicle_ext.vehicle
				vehicle.pos_history[-1] += next_lane_ext.length
				next_lane_ext.update_overflowing_by(vehicle)

			else:
				vehicle_ext.move_to(next_lane_ext, step)
				next_lane_ext.update_overflowing()

		lane_ext.update_overflowing()

	for next_lane_ext in loop_tail_buffer_dict:
		var buffered_vehicle_exts = loop_tail_buffer_dict[next_lane_ext]

		for vehicle_ext in buffered_vehicle_exts:
			vehicle_ext.vehicle.pos_history[-1] -= next_lane_ext.length
			vehicle_ext.move_to(next_lane_ext, step)


static func _is_blocking(content_ext: SimulatorContentExtension) -> bool:
	return content_ext.is_blocking


static func _is_blocked(content_ext: SimulatorContentExtension) -> bool:
	return content_ext.is_blocked
