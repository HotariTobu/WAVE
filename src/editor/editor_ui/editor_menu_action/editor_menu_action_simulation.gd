extends Node


func open_simulator_window():
	$SimulatorWindow.show()
	$SimulatorWindow.grab_focus()


func open_player_window():
	$PlayerWindow.show()
	$PlayerWindow.grab_focus()


func select_simulation():
	$SimulationOpenFileDialog.show()


func _on_simulator_window_close_requested():
	$SimulatorWindow.hide()


func _on_player_window_close_requested():
	$PlayerWindow.hide()


func _on_simulation_completed(simulation):
	player_global.simulation = simulation
	$PlayConfirmationDialog.show()


func _on_play_confirmation_dialog_confirmed():
	open_player_window()


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
	$ActionQueue.push(open_player_window)
