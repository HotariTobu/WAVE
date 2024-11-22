extends HBoxContainer

const CrossIcon = preload("res://assets/cross.svg")

var parameter: ParameterData:
	get:
		return _parameter

var _parameter = ParameterData.new()

var _vehicle_length_cells: Array[Control]:
	get:
		return _vehicle_length_cells
	set(next):
		var prev = _vehicle_length_cells

		for child in prev:
			child.queue_free()

		for child in next:
			_vehicle_length_option_container.add_child(child)

		_vehicle_length_cells = next

@onready var _source = BindingSource.new(_parameter)

@onready var _vehicle_length_option_container = %VehicleLengthOptionContainer


func _ready():
	_parameter.step_delta = setting.default_step_delta
	_parameter.max_step = setting.default_max_step
	_parameter.random_seed = setting.default_random_seed

	_parameter.vehicle_spawn_before_start = setting.default_vehicle_spawn_before_start
	_parameter.vehicle_spawn_after_start = setting.default_vehicle_spawn_after_start

	_parameter.vehicle_length_options = setting.default_vehicle_length_options

	_parameter.vehicle_relative_speed_range = setting.default_vehicle_relative_speed_range
	_parameter.vehicle_relative_speed_mean = setting.default_vehicle_relative_speed_mean
	_parameter.vehicle_max_speed_range = setting.default_vehicle_max_speed_range
	_parameter.vehicle_max_speed_mean = setting.default_vehicle_max_speed_mean
	_parameter.vehicle_min_following_distance_range = setting.default_vehicle_min_following_distance_range
	_parameter.vehicle_min_following_distance_mean = setting.default_vehicle_min_following_distance_mean
	_parameter.vehicle_max_following_distance_range = setting.default_vehicle_max_following_distance_range
	_parameter.vehicle_max_following_distance_mean = setting.default_vehicle_max_following_distance_mean

	_source.bind(&"step_delta").to(%StepDeltaBox, &"value", &"value_changed")
	_source.bind(&"max_step").to(%MaxStepBox, &"value", &"value_changed")
	_source.bind(&"random_seed").to(%RandomSeed, &"value", &"value_changed")

	_source.bind(&"vehicle_spawn_before_start").to_check_button(%VehicleSpawnBeforeStartSwitch)
	_source.bind(&"vehicle_spawn_after_start").to_check_button(%VehicleSpawnAfterStartSwitch)

	var vehicle_length_option_cell_creator = RandomOptionCellCreator.new()
	vehicle_length_option_cell_creator.suffix = " m"
	_source.bind(&"vehicle_length_options").using(vehicle_length_option_cell_creator).to(self, &"_vehicle_length_cells")
	vehicle_length_option_cell_creator.option_removed.connect(_on_vehicle_length_option_remove_button_pressed)

	_source.bind(&"vehicle_relative_speed_range").to(%VehicleRelativeSpeedRangePanel, &"range_value", &"range_value_changed")
	_source.bind(&"vehicle_relative_speed_mean").to(%VehicleRelativeSpeedMeanBox, &"value", &"value_changed")
	_source.bind(&"vehicle_max_speed_range").to(%VehicleMaxSpeedRangePanel, &"range_value", &"range_value_changed")
	_source.bind(&"vehicle_max_speed_mean").to(%VehicleMaxSpeedMeanBox, &"value", &"value_changed")
	_source.bind(&"vehicle_min_following_distance_range").to(%VehicleMinFollowingDistanceRangePanel, &"range_value", &"range_value_changed")
	_source.bind(&"vehicle_min_following_distance_mean").to(%VehicleMinFollowingDistanceMeanBox, &"value", &"value_changed")
	_source.bind(&"vehicle_max_following_distance_range").to(%VehicleMaxFollowingDistanceRangePanel, &"range_value", &"range_value_changed")
	_source.bind(&"vehicle_max_following_distance_mean").to(%VehicleMaxFollowingDistanceMeanBox, &"value", &"value_changed")

	for child in $GridContainer.get_children():
		child.size_flags_horizontal = SIZE_EXPAND_FILL


func _on_child_entered_tree(node: Node) -> void:
	if node is LineEdit:
		node.select_all_on_focus = true
		node.text_submitted.connect(node.release_focus.unbind(1))

	elif node is Container:
		node.child_entered_tree.connect(_on_child_entered_tree)


func _on_vehicle_length_option_add_button_pressed():
	var new_vehicle_length_options = _parameter.vehicle_length_options.duplicate()
	new_vehicle_length_options.append(ParameterData.RandomOption.new(0.0, 0.0))
	_source.vehicle_length_options = new_vehicle_length_options


func _on_vehicle_length_option_remove_button_pressed(option: ParameterData.RandomOption):
	var new_vehicle_length_options = _parameter.vehicle_length_options.duplicate()
	new_vehicle_length_options.erase(option)
	_source.vehicle_length_options = new_vehicle_length_options


class RandomOptionCellCreator:
	extends BindingConverter

	signal option_removed(option: ParameterData.RandomOption)

	var prefix: String
	var suffix: String

	var _option_source_dict: Dictionary

	func source_to_target(source_value: Variant) -> Variant:
		return _create_cells(source_value)

	func _create_cells(options: Array[ParameterData.RandomOption]) -> Array[Control]:
		var cells: Array[Control] = []

		for option in options:
			cells += _create_cell(option)

		return cells

	func _create_cell(option: ParameterData.RandomOption) -> Array[Control]:
		var source = _option_source_dict.get_or_add(option, BindingSource.new(option))

		var value_box = NumericBox.new()
		value_box.prefix = prefix
		value_box.suffix = suffix
		source.bind(&"value").to(value_box, &"value", value_box.value_changed)

		var weight_box = NumericBox.new()
		weight_box.min_value = 0
		source.bind(&"weight").to(weight_box, &"value", weight_box.value_changed)

		var remove_button = IconButton.new(CrossIcon)
		remove_button.pressed.connect(_on_remove_button_pressed.bind(option))

		return [value_box, weight_box, remove_button] as Array[Control]

	func _on_remove_button_pressed(option: ParameterData.RandomOption):
		option_removed.emit(option)
