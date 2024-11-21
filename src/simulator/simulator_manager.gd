class_name SimulatorManager

signal status_changed(new_status: Status)

enum Status { INITIALIZED, PREPARING, PREPARED, RUNNING, COMPLETED, CANCELED }

var status: Status:
	get:
		return _status

var current_step: int:
	get:
		return _current_step

var _status: Status = Status.INITIALIZED:
	get:
		return _status
	set(next):
		var prev = _status
		if prev == next:
			return

		_status = next
		status_changed.emit(next)

var _is_canceled: bool = false
var _is_prepared: bool = false

var _current_step: int

var _parameter: ParameterData
var _network: NetworkData

var _prepared_data: SimulatorPreparedData


func _init(parameter: ParameterData, network: NetworkData):
	_parameter = parameter
	_network = network


func prepare() -> void:
	if _status != Status.INITIALIZED:
		return

	_status = Status.PREPARING
	_is_canceled = false
	_is_prepared = false

	_current_step = 0

	_prepared_data = SimulatorPreparedData.new(_should_exit, _parameter, _network)

	if _should_exit():
		return

	_status = Status.PREPARED
	_is_prepared = true


func start() -> SimulationData:
	if not _is_prepared:
		return null

	if _status in [Status.INITIALIZED, Status.PREPARING, Status.RUNNING]:
		return null

	_status = Status.RUNNING
	_is_canceled = false
	var simulation = SimulationData.new()

	for step in range(_parameter.max_step):
		_current_step = step

		if _should_exit():
			return null

		OS.delay_msec(1000)

	_status = Status.COMPLETED
	return simulation


func stop() -> void:
	_is_canceled = true


func _should_exit():
	if _is_canceled:
		_status = Status.CANCELED
		return true

	return false
