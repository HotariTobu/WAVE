extends Node


func open_simulator_window():
	$SimulatorWindow.show()


func open_player_window():
	$SimulationOpenFileDialog.show()


func _on_simulator_window_close_requested():
	$SimulatorWindow.hide()


func _on_player_window_close_requested():
	$PlayerWindow.hide()


func _on_simulation_open_file_dialog_file_selected(path):
	var result = CommonIO.read_data(path, SimulationData)
	if not result.ok:
		$ErrorDialog.show_error("Failed to open file", result.error)
		return

	var simulation = result.data as SimulationData
	if simulation == null:
		$ErrorDialog.show_error("Opened invalid simulation file")
		return

	player_global.simulation = simulation
	$ActionQueue.push($PlayerWindow.show)
