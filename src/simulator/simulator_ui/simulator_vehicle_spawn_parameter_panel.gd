extends GridContainer

var parameter: VehicleData.SpawnParameterData:
	get:
		return parameter
	set(next):
		var prev = parameter
		if prev == next:
			return

		if prev != null:
			_unbind_cells(prev)

		if next != null:
			_bind_cells(next)

		parameter = next

var _source_dict: Dictionary


func _bind_cells(next_parameter: VehicleData.SpawnParameterData):
	var source = BindingSource.new(next_parameter)
	_source_dict[next_parameter] = source

	source.bind(&"weight").to(%WeightBox, &"value", &"value_changed")

	source.bind(&"length").to(%LengthBox, &"value", &"value_changed")

	source.bind(&"high_speed_acceleration_range").to(%HighSpeedAccelerationRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"high_speed_acceleration_mean").to(%HighSpeedAccelerationMeanBox, &"value", &"value_changed")

	source.bind(&"high_speed_range").to(%HighSpeedRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"high_speed_mean").to(%HighSpeedMeanBox, &"value", &"value_changed")
	source.bind(&"max_speed_range").to(%MaxSpeedRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"max_speed_mean").to(%MaxSpeedMeanBox, &"value", &"value_changed")

	source.bind(&"zero_speed_distance_range").to(%ZeroSpeedDistanceRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"zero_speed_distance_mean").to(%ZeroSpeedDistanceMeanBox, &"value", &"value_changed")
	source.bind(&"half_speed_distance_range").to(%HalfSpeedDistanceRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"half_speed_distance_mean").to(%HalfSpeedDistanceMeanBox, &"value", &"value_changed")
	source.bind(&"high_speed_distance_range").to(%HighSpeedDistanceRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"high_speed_distance_mean").to(%HighSpeedDistanceMeanBox, &"value", &"value_changed")


func _unbind_cells(prev_parameter: VehicleData.SpawnParameterData):
	var source = _source_dict[prev_parameter]
	_source_dict.erase(prev_parameter)

	source.unbind(&"weight").from(%WeightBox, &"value")

	source.unbind(&"length").from(%LengthBox, &"value")

	source.unbind(&"high_speed_acceleration_range").from(%HighSpeedAccelerationRangePanel, &"range_value")
	source.unbind(&"high_speed_acceleration_mean").from(%HighSpeedAccelerationMeanBox, &"value")

	source.unbind(&"high_speed_range").from(%HighSpeedRangePanel, &"range_value")
	source.unbind(&"high_speed_mean").from(%HighSpeedMeanBox, &"value")
	source.unbind(&"max_speed_range").from(%MaxSpeedRangePanel, &"range_value")
	source.unbind(&"max_speed_mean").from(%MaxSpeedMeanBox, &"value")

	source.unbind(&"zero_speed_distance_range").from(%ZeroSpeedDistanceRangePanel, &"range_value")
	source.unbind(&"zero_speed_distance_mean").from(%ZeroSpeedDistanceMeanBox, &"value")
	source.unbind(&"half_speed_distance_range").from(%HalfSpeedDistanceRangePanel, &"range_value")
	source.unbind(&"half_speed_distance_mean").from(%HalfSpeedDistanceMeanBox, &"value")
	source.unbind(&"high_speed_distance_range").from(%HighSpeedDistanceRangePanel, &"range_value")
	source.unbind(&"high_speed_distance_mean").from(%HighSpeedDistanceMeanBox, &"value")
