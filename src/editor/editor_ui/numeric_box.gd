class_name NumericBox
extends LineEdit

signal value_changed(new_value: float)

@export var prefix: String = '':
	get:
		return prefix
	set(value):
		prefix = value
		_update_text()
@export var suffix: String = '':
	get:
		return suffix
	set(value):
		suffix = value
		_update_text()

@export var min_value: float = -INF:
	get:
		return min_value
	set(value):
		min_value = value
		_update_value()
@export var max_value: float = INF:
	get:
		return max_value
	set(value):
		max_value = value
		_update_value()

@export var value = null:
	get:
		return value
	set(new_value):
		if new_value == null:
			value = new_value
			_is_valid = false
		else:
			value = clamp(new_value, min_value, max_value)
			_is_valid = true
		_update_text()

var is_valid: bool:
	get:
		return _is_valid

var _is_valid: bool = false

func _init():
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _ready():
	_update_text()

func _on_focus_entered():
	_update_text()
	text_submitted.connect(_on_text_submitted)

func _on_focus_exited():
	if not Input.is_action_pressed(&'ui_cancel'):
		_update_value()

	_update_text()
	text_submitted.disconnect(_on_text_submitted)


func _on_text_submitted(_new_text: String):
	_update_value()

func _update_value():
	_is_valid = text.is_valid_float()
	if not _is_valid:
		return

	var prev = value
	var next = clamp(float(text), min_value, max_value)

	if prev == next:
		return

	value = next
	value_changed.emit(next)

func _update_text():
	if value == null:
		text = ''
	elif has_focus():
		text = str(value)
	else:
		text = prefix + str(value) + suffix
