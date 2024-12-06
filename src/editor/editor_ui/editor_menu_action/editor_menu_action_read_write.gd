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
	var result = CommonIO.read_data(path, NetworkData)
	if not result.ok:
		$ErrorDialog.show_error("Failed to open file", result.error)
		return

	var network = result.data as NetworkData
	if network == null:
		$ErrorDialog.show_error("Opened invalid network file")
		return

	_editor_global.set_network(network)
	_editor_global.network_file_path = path


func _write_network(path: String):
	var network = _editor_global.get_network()

	var result = CommonIO.write_data(path, NetworkData, network)
	if not result.ok:
		$ErrorDialog.show_error("Failed to open file", result.error)
		return

	_editor_global.network_file_path = path
