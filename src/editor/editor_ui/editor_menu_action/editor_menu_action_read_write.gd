extends Node

var _editor_global = editor_global


func open_network():
	$NetworkOpenFileDialog.show()


func save_network():
	var path = _editor_global.network_file_path
	if path == "":
		$NetworkSaveFileDialog.show()
		return

	_write_network(path)


func save_network_as():
	$NetworkSaveFileDialog.show()


func _on_network_open_file_dialog_file_selected(path):
	_read_network(path)


func _on_network_save_file_dialog_file_selected(path):
	_write_network(path)


func _read_network(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		var error = FileAccess.get_open_error()
		_show_error("Failed to open file", error)
		return

	var network_dict = file.get_var()
	file.close()

	if network_dict == null:
		_show_error("Opened invalid format file")
		return

	var network = NetworkData.from_dict(network_dict)
	if network == null:
		_show_error("Opened invalid network file")
		return

	_editor_global.set_network(network)
	_editor_global.network_file_path = path


func _write_network(path: String):
	var network = _editor_global.get_network()
	var network_dict = NetworkData.to_dict(network)

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		_show_error("Failed to open file", error)
		return

	file.store_var(network_dict)
	file.close()

	_editor_global.network_file_path = path


func _show_error(message: String, error = null):
	var text: String

	if error == null:
		text = message
	else:
		text = "%s: %s" % [message, error_string(error)]

	$ErrorAcceptDialog.dialog_text = text
	$ErrorAcceptDialog.show()
