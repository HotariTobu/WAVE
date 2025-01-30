extends Node

signal completed(simulation: SimulationData)

enum NetworkSource { MEMORY, FILE }

const Status = SimulatorManager.Status

var _data = BindingSource.new(Data.new(), &"notified")

var _manager: SimulatorManager = null
var _thread = Thread.new()
var _mutex = Mutex.new()

@onready var _show_error = $ErrorDialog.show_error


func _ready():
	_data.bind(&"parameter").to($ParameterPanel, &"parameter")

	var case = CaseBindingConverter
	_data.bind(&"network_source").using(case.new(NetworkSource.MEMORY)).to_check_box(%NetworkMemoryOption)
	_data.bind(&"network_source").using(case.new(NetworkSource.FILE)).to_check_box(%NetworkFileOption)
	_data.bind(&"network_source").using(case.new(NetworkSource.FILE)).to(%NetworkPathPanel, &"enable")
	_data.bind(&"network_file_path").to(%NetworkPathPanel, &"path", &"path_changed")

	_data.bind(&"status").using(_get_status_label).to_label(%StatusLabel)
	_data.bind(&"status").using(_status_to_start_disabled).to(%StartButton, &"disabled")
	_data.bind(&"status").using(_status_to_cancel_disabled).to(%CancelButton, &"disabled")

	var invert_converter = InvertBoolBindingConverter.new()
	_data.bind(&"indeterminate").to(%ProgressBar, &"indeterminate")
	_data.bind(&"sync_progress").using(invert_converter).to($ProgressBarTimer, &"paused")

	_data.bind(&"max_progress_value").using(BindingUtils.to_float).to(%ProgressBar, &"max_value")
	_data.bind(&"progress_value").using(BindingUtils.to_float).to_progress_bar(%ProgressBar)

	_data.bind(&"auto_save").to_check_box(%AutoSaveBox)
	_data.bind(&"simulation").using(case.new(Data.NULL_SIMULATION)).to(%SaveButton, &"disabled")
	_data.bind(&"save_path").to(%SavePathPanel, &"path", &"path_changed")

	_data.bind(&"auto_dump").to_check_box(%AutoDumpBox)
	_data.bind(&"simulation").using(case.new(Data.NULL_SIMULATION)).to(%DumpButton, &"disabled")
	_data.bind(&"dump_path").to(%DumpPathPanel, &"path", &"path_changed")


func _exit_tree():
	_on_cancel_button_pressed()


func _status_to_start_disabled(status: Status) -> bool:
	return status not in [Status.INITIALIZED, Status.COMPLETED, Status.CANCELED, Status.ERROR]


func _status_to_cancel_disabled(status: Status) -> bool:
	return status not in [Status.PREPARING, Status.RUNNING]


func _on_start_button_pressed():
	if _thread.is_started():
		return

	_thread.start(_run_simulation)


func _on_cancel_button_pressed():
	if _manager == null:
		return

	if not _thread.is_started():
		return

	_mutex.lock()
	_manager.stop()
	_mutex.unlock()

	_thread.wait_to_finish()


func _run_simulation() -> SimulationData:
	_mutex.lock()
	var network_source = _data.network_source
	_mutex.unlock()

	var network: NetworkData = null

	match network_source:
		NetworkSource.MEMORY:
			_mutex.lock()
			var network_dict = NetworkData.to_dict(editor_global.get_network())
			_mutex.unlock()

			network = NetworkData.from_dict(network_dict)

		NetworkSource.FILE:
			_mutex.lock()
			var network_file_path = _data.network_file_path
			_mutex.unlock()

			network = _read_network(network_file_path)

	var manager = SimulatorManager.new()

	_mutex.lock()
	var parameter_dict = ParameterData.to_dict(_data.parameter)
	var parameter = ParameterData.from_dict(parameter_dict)

	_data.set_deferred(&"status", manager.status)
	_data.set_deferred(&"max_progress_value", parameter.max_step)

	_manager = manager
	_manager.status_changed.connect(_on_simulator_status_changed.call_deferred)
	_mutex.unlock()

	manager.prepare(parameter, network)
	var simulation = manager.start()

	if simulation == null:
		return Data.NULL_SIMULATION

	return simulation


func _on_simulator_status_changed(new_status):
	_data.status = new_status

	if new_status == Status.RUNNING:
		_data.progress_value = 0

	elif new_status == Status.COMPLETED:
		var simulation = _thread.wait_to_finish()
		_on_completed(simulation)

	elif new_status == Status.ERROR:
		_thread.wait_to_finish()


func _on_completed(simulation: SimulationData):
	_data.progress_value = _data.max_progress_value
	_data.simulation = simulation

	completed.emit(simulation)

	if _data.auto_save:
		_write_simulation(_data.save_path, simulation)

	if _data.auto_dump:
		_dump(_data.dump_path, simulation)


func _on_save_button_pressed():
	var simulation = _data.simulation
	if simulation == Data.NULL_SIMULATION:
		return

	_write_simulation(_data.save_path, simulation)


func _on_dump_button_pressed():
	var simulation = _data.simulation
	if simulation == Data.NULL_SIMULATION:
		return

	_dump(_data.dump_path, simulation)


func _on_progress_bar_timer_timeout():
	if _manager == null:
		return

	_mutex.lock()
	var current_step = _manager.current_step
	_mutex.unlock()

	_data.progress_value = current_step


func _read_network(path: String) -> NetworkData:
	var result = CommonIO.read_data(path, NetworkData)
	if not result.ok:
		_show_error.call_deferred("Failed to open file", result.error)
		return null

	var network = result.data as NetworkData
	if network == null:
		_show_error.call_deferred("Opened invalid network file")
		return null

	return network


func _write_simulation(path: String, simulation: SimulationData):
	var result = CommonIO.write_data(path, SimulationData, simulation)
	if not result.ok:
		_show_error.call_deferred("Failed to write the simulation result", result.error)


func _dump(path: String, simulation: SimulationData):
	if not DirAccess.dir_exists_absolute(path):
		_show_error.call_deferred("Not found dump dir", ERR_DOES_NOT_EXIST)
		return

	DirAccess.remove_absolute(path)

	var result = Dumper.dump(path, simulation)
	if result != OK:
		_show_error.call_deferred("Failed to dump", result)


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
		Status.ERROR:
			return "Error!"
		_:
			return ""


class Data:
	signal notified(property: StringName)

	static var NULL_SIMULATION = SimulationData.new()

	var parameter: ParameterData = ParameterData.new_default()

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

	var auto_save: bool
	var save_path: String

	var auto_dump: bool
	var dump_path: String
