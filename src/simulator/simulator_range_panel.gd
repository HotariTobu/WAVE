extends HBoxContainer

signal range_value_changed(new_range_value: ParameterData.IntRange)

@export var prefix: String:
	get:
		return prefix
	set(value):
		prefix = value
		$BeginBox.prefix = value
		$EndBox.prefix = value

@export var suffix: String:
	get:
		return suffix
	set(value):
		suffix = value
		$BeginBox.suffix = value
		$EndBox.suffix = value

@export var min_value: float:
	get:
		return $BeginBox.min_value
	set(value):
		$BeginBox.min_value = value

@export var max_value: float:
	get:
		return $EndBox.max_value
	set(value):
		$EndBox.max_value = value

var range_value: ParameterData.IntRange:
	get:
		return range_value
	set(value):
		range_value = value
		_begin_box.value = value.begin
		_begin_box.max_value = value.end
		_end_box.value = value.end
		_end_box.min_value = value.begin

@onready var _begin_box = $BeginBox
@onready var _end_box = $EndBox


func _on_begin_box_value_changed(new_value):
	_end_box.min_value = new_value
	range_value.begin = new_value
	var new_range_value = ParameterData.IntRange.new(new_value, range_value.end)
	range_value_changed.emit(new_range_value)


func _on_end_box_value_changed(new_value):
	_begin_box.max_value = new_value
	range_value.end = new_value
	var new_range_value = ParameterData.IntRange.new(range_value.begin, new_value)
	range_value_changed.emit(new_range_value)
