extends VBoxContainer

signal value_changed(new_value: Vector2)

@export var value: Vector2:
	get:
		return value
	set(new_value):
		value = new_value
		_x_box.value = new_value.x
		_y_box.value = new_value.y

@onready var _x_box = $XRow/NumericBox
@onready var _y_box = $YRow/NumericBox


func _ready():
	$XRow/Label.size_flags_horizontal = SIZE_FILL
	$YRow/Label.size_flags_horizontal = SIZE_FILL


func get_x_box() -> NumericBox:
	return _x_box


func get_y_box() -> NumericBox:
	return _y_box


func _on_x_box_value_changed(new_value):
	value.x = new_value
	value_changed.emit(value)


func _on_y_box_value_changed(new_value):
	value.y = new_value
	value_changed.emit(value)
