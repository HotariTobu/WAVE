extends HBoxContainer

const CrossIcon = preload("res://assets/cross.svg")

var parameter: ParameterData:
	get:
		return _parameter

var _parameter = ParameterData.new_default()

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
	_source.bind(&"step_delta").to(%StepDeltaBox, &"value", &"value_changed")
	_source.bind(&"max_step").to(%MaxStepBox, &"value", &"value_changed")
	_source.bind(&"random_seed").to(%RandomSeed, &"value", &"value_changed")

	for child in $GridContainer.get_children():
		child.size_flags_horizontal = SIZE_EXPAND_FILL


func _on_child_entered_tree(node: Node) -> void:
	if node is LineEdit:
		node.select_all_on_focus = true
		node.text_submitted.connect(node.release_focus.unbind(1))

	elif node is Container:
		node.child_entered_tree.connect(_on_child_entered_tree)
