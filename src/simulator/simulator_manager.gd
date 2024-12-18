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

var _parameter: ParameterData
var _network: NetworkData

var _current_step: int
var _iterator: SimulatorIterator


func _init(parameter: ParameterData, network: NetworkData):
	_parameter = parameter
	_network = network


func prepare() -> void:
	if _status != Status.INITIALIZED:
		return

	_status = Status.PREPARING
	_is_canceled = false

	_current_step = 0
	_iterator = null
	_iterator = SimulatorIterator.new(_should_exit, _parameter, _network)

	if _should_exit():
		return

	_status = Status.PREPARED


func start() -> SimulationData:
	if _iterator == null:
		return null

	if _status in [Status.INITIALIZED, Status.PREPARING, Status.RUNNING]:
		return null

	_status = Status.RUNNING
	_is_canceled = false

	for step in range(_parameter.max_step):
		if _should_exit():
			return null

		_current_step = step
		_iterator.iterate(step)

	var simulation = _iterator.simulation

	_status = Status.COMPLETED
	return simulation


func stop() -> void:
	_is_canceled = true


func _should_exit():
	if _is_canceled:
		_status = Status.CANCELED
		return true

	return false
