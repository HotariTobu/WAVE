extends Node

enum NetworkSource { MEMORY, FILE }

const Status = SimulatorManager.Status

var _parameter = ParameterData.new()

var _data = BindingSource.new(Data.new(), &"notified")

var _simulator: SimulatorManager = null
var _thread = Thread.new()
var _mutex = Mutex.new()


func _ready():
	_parameter = $ParameterPanel.parameter

	_data.network_file_path = editor_global.network_file_path

	var case = CaseBindingConverter
	_data.bind(&"network_source").using(case.new(NetworkSource.MEMORY)).to_check_box(%NetworkMemoryOption)
	_data.bind(&"network_source").using(case.new(NetworkSource.FILE)).to_check_box(%NetworkFileOption)
	_data.bind(&"network_source").using(case.new(NetworkSource.FILE)).to(%NetworkPathPanel, &"enable")
	_data.bind(&"network_file_path").to(%NetworkPathPanel, &"path", &"path_changed")

	_data.bind(&"status").using(_status_hook).using(_get_status_label).to_label(%StatusLabel)
	_data.bind(&"status").using(_status_to_start_disabled).to(%StartButton, &"disabled")
	_data.bind(&"status").using(_status_to_cancel_disabled).to(%CancelButton, &"disabled")

	var invert_converter = InvertBoolBindingConverter.new()
	_data.bind(&"indeterminate").to(%ProgressBar, &"indeterminate")
	_data.bind(&"sync_progress").using(invert_converter).to($ProgressBarTimer, &"paused")

	_data.bind(&"max_progress_value").using(BindingUtils.to_float).to(%ProgressBar, &"max_value")
	_data.bind(&"progress_value").using(BindingUtils.to_float).to_progress_bar(%ProgressBar)

	_data.bind(&"simulation").using(case.new(Data.NULL_SIMULATION)).to(%SaveButton, &"disabled")


func _exit_tree():
	_on_cancel_button_pressed()


func _status_hook(status: Status) -> Status:
	if status == Status.RUNNING:
		_data.progress_value = 0

	elif status == Status.COMPLETED:
		_data.progress_value = _data.max_progress_value
		_data.simulation = _thread.wait_to_finish()
		
		$SimulationSaveFileDialog.show()

	return status


func _status_to_start_disabled(status: Status) -> bool:
	return status not in [Status.INITIALIZED, Status.COMPLETED, Status.CANCELED]


func _status_to_cancel_disabled(status: Status) -> bool:
	return status not in [Status.PREPARING, Status.RUNNING]


func _run_simulation() -> SimulationData:
	_mutex.lock()
	var parameter_dict = ParameterData.to_dict(_parameter)
	var parameter = ParameterData.from_dict(parameter_dict)
	var network_source = _data.network_source
	var network_file_path = _data.network_file_path
	_mutex.unlock()

	var network: NetworkData
	match network_source:
		NetworkSource.MEMORY:
			_mutex.lock()
			var network_dict = NetworkData.to_dict(editor_global.get_network())
			network = NetworkData.from_dict(network_dict)
			_mutex.unlock()

		NetworkSource.FILE:
			network = _read_network(network_file_path)

	var simulator = SimulatorManager.new(parameter, network)
	simulator.status_changed.connect(_on_simulator_status_changed)

	_mutex.lock()
	_simulator = simulator
	_data.set_deferred(&"status", Status.INITIALIZED)
	_data.set_deferred(&"max_progress_value", parameter.max_step)
	_mutex.unlock()

	simulator.prepare()
	var simulation = simulator.start()

	if simulation == null:
		return Data.NULL_SIMULATION

	return simulation


func _on_start_button_pressed():
	if _thread.is_started():
		return

	_thread.start(_run_simulation)


func _on_cancel_button_pressed():
	if not _thread.is_started():
		return

	_mutex.lock()
	_simulator.stop()
	_mutex.unlock()

	_thread.wait_to_finish()


func _on_save_button_pressed():
	if _data.simulation == Data.NULL_SIMULATION:
		return

	$SimulationSaveFileDialog.show()


func _on_simulator_status_changed(new_status):
	_mutex.lock()
	_data.set_deferred(&"status", new_status)
	_mutex.unlock()


func _on_progress_bar_timer_timeout():
	if _simulator == null:
		return

	_mutex.lock()
	var current_step = _simulator.current_step
	_mutex.unlock()

	_data.progress_value = current_step


func _on_simulation_save_file_dialog_file_selected(path):
	var simulation = _data.simulation
	if simulation == Data.NULL_SIMULATION:
		return

	_write_simulation(path, simulation)


func _read_network(path: String) -> NetworkData:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		var error = FileAccess.get_open_error()
		_show_error("Failed to open file", error)
		return null

	var network_dict = file.get_var()
	file.close()

	if network_dict == null:
		_show_error("Opened invalid format file")
		return null

	var network = NetworkData.from_dict(network_dict)
	if network == null:
		_show_error("Opened invalid network file")
		return null

	return network


func _write_simulation(path: String, simulation: SimulationData):
	var simulation_dict = SimulationData.to_dict(simulation)

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		_show_error("Failed to open file", error)
		return

	file.store_var(simulation_dict)
	file.close()


func _show_error(message: String, error = null):
	var text: String

	if error == null:
		text = message
	else:
		text = "%s: %s" % [message, error_string(error)]

	_mutex.lock()
	$ErrorAcceptDialog.dialog_text = text
	$ErrorAcceptDialog.show()
	_mutex.unlock()


static func _get_status_label(status: Status) -> String:
	match status:
		Status.INITIALIZED:
			return "Initialized!"
		Status.PREPARING:
			return "Preparing..."
		Status.PREPARED:
			return "Prepared!"
		Status.RUNNING:
			return "Running..."
		Status.COMPLETED:
			return "Completed!"
		Status.CANCELED:
			return "Canceled!"
		_:
			return ""


class Data:
	signal notified(property: StringName)

	static var NULL_SIMULATION = SimulationData.new()

	var network_source: NetworkSource
	var network_file_path: String

	var status: Status:
		get:
			return status
		set(value):
			status = value

			indeterminate = value == Status.PREPARING
			sync_progress = value == Status.RUNNING

			notified.emit(&"indeterminate")
			notified.emit(&"sync_progress")

	var indeterminate: bool
	var sync_progress: bool

	var max_progress_value: int
	var progress_value: int

	var simulation: SimulationData = NULL_SIMULATION
