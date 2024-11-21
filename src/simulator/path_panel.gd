class_name PathPanel
extends HBoxContainer

signal path_changed(new_path: String)

@export var path: String:
	get:
		return path
	set(value):
		path = value
		$PathBox.text = value

@export var enable: bool = true:
	get:
		return enable
	set(value):
		enable = value
		$PathBox.editable = value
		$BrowseButton.disabled = not value

@export var file_mode: FileDialog.FileMode:
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


func get_path_box() -> LineEdit:
	return _path_box


func get_browse_button() -> Button:
	return _browse_button


func get_file_dialog() -> FileDialog:
	return _file_dialog


func _on_path_box_text_submitted(new_text):
	if FileAccess.file_exists(new_text):
		_update_path(new_text)

	elif DirAccess.dir_exists_absolute(new_text):
		_update_path(new_text)


func _on_browse_button_pressed():
	_file_dialog.show()


func _on_file_dialog_file_selected(selected_path):
	_update_path(selected_path)


func _on_file_dialog_dir_selected(selected_dir):
	_update_path(selected_dir)


func _update_path(new_path: String):
	path = new_path
	path_changed.emit(new_path)
