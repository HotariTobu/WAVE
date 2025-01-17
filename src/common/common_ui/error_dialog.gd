class_name ErrorDialog
extends AcceptDialog


func _init():
	title = "Error!"
	initial_position = WINDOW_INITIAL_POSITION_CENTER_OTHER_SCREEN
	force_native = true


func show_error(message: String, error = null):
	if error == null:
		dialog_text = message
	else:
		dialog_text = "%s: %s" % [message, error_string(error)]

	show()
