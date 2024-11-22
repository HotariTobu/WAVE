extends Node


func open_simulator_window():
	$SimulatorWindow.show()


func _on_simulator_window_close_requested():
	$SimulatorWindow.hide()
