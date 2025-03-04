class_name PathPanel
extends HBoxContainer

signal path_changed(new_path: String)

@export var path: String:
	get:
		return $PathBox.text
	set(value):
		$PathBox.text = value

@export var enable: bool = true:
	get:
		return enable
	set(value):
		enable = value
		$PathBox.editable = value
		$BrowseButton.disabled = not value

@export var file_mode: FileDialog.FileMode = FileDialog.FILE_MODE_SAVE_FILE:
	get:
		return $FileDialog.file_mode
	set(value):
		$FileDialog.file_mode = value

@export var filters: PackedStringArray:
	get:
		return $FileDialog.filters
	set(value):
		$FileDialog.filters = value

@onready var _path_box = $PathBox
@onready var _browse_button = $BrowseButton
@onready var _file_dialog = $FileDialog

var _last_path: String


func get_path_box() -> LineEdit:
	return _path_box


func get_browse_button() -> Button:
	return _browse_button


func get_file_dialog() -> FileDialog:
	return _file_dialog


func _on_path_box_focus_exited():
	_update_path(path)


func _on_browse_button_pressed():
	_file_dialog.show()


func _on_file_dialog_selected(selected_path):
	_update_path(selected_path)


func _update_path(new_path: String):
	if _last_path == new_path:
		return

	_last_path = new_path

	path = new_path
	path_changed.emit(new_path)
