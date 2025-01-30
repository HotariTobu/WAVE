extends GridContainer

var parameter: WalkerData.SpawnParameterData:
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


func _bind_cells(next_parameter: WalkerData.SpawnParameterData):
	var source = BindingSource.new(next_parameter)
	_source_dict[next_parameter] = source

	source.bind(&"weight").to(%WeightBox, &"value", &"value_changed")

	source.bind(&"radius").to(%RadiusBox, &"value", &"value_changed")

	source.bind(&"speed_range").to(%SpeedRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"speed_mean").to(%SpeedMeanBox, &"value", &"value_changed")
	source.bind(&"overtake_speed_range").to(%OvertakeSpeedRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"overtake_speed_mean").to(%OvertakeSpeedMeanBox, &"value", &"value_changed")

	source.bind(&"personal_distance_range").to(%PersonalDistanceRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"personal_distance_mean").to(%PersonalDistanceMeanBox, &"value", &"value_changed")
	source.bind(&"public_distance_range").to(%PublicDistanceRangePanel, &"range_value", &"range_value_changed")
	source.bind(&"public_distance_mean").to(%PublicDistanceMeanBox, &"value", &"value_changed")


func _unbind_cells(prev_parameter: WalkerData.SpawnParameterData):
	var source = _source_dict[prev_parameter]
	_source_dict.erase(prev_parameter)

	source.unbind(&"weight").from(%WeightBox, &"value")

	source.unbind(&"radius").from(%RadiusBox, &"value")

	source.unbind(&"speed_range").from(%SpeedRangePanel, &"range_value")
	source.unbind(&"speed_mean").from(%SpeedMeanBox, &"value")
	source.unbind(&"overtake_speed_range").from(%OvertakeSpeedRangePanel, &"range_value")
	source.unbind(&"overtake_speed_mean").from(%OvertakeSpeedMeanBox, &"value")

	source.unbind(&"personal_distance_range").from(%PersonalDistanceRangePanel, &"range_value")
	source.unbind(&"personal_distance_mean").from(%PersonalDistanceMeanBox, &"value")
	source.unbind(&"public_distance_range").from(%PublicDistanceRangePanel, &"range_value")
	source.unbind(&"public_distance_mean").from(%PublicDistanceMeanBox, &"value")
