extends Node

signal simulation_changed(new_simulation: SimulationData)

var simulation: SimulationData:
	get:
		return simulation
	set(value):
		simulation = value
		_reset()
		simulation_changed.emit(value)

var content_db: PlayerContentDataDB

var exact_step: float:
	get:
		return exact_step
	set(value):
		exact_step = value
		step_frac = fmod(value, 1.0)
		prev_step = floori(value)
		next_step = ceili(value)
		if prev_step == next_step:
			next_step += 1

var step_frac: float
var prev_step: int
var next_step: int

var data = BindingSource.new(Data.new())


func _ready():
	data.bind(&"time").using(_get_step).to(self, &"exact_step")


func _process(delta):
	data.time += delta

	if data.time > data.max_time:
		data.set_deferred(&"time", data.max_time)
		data.set_deferred(&"playing", false)


func _reset():
	content_db = PlayerContentDataDB.new(simulation.network)

	data.time = 0.0
	data.max_time = simulation.parameter.max_step * simulation.parameter.step_delta
	data.playing = false


func _get_step(time: float) -> float:
	if simulation == null:
		return NAN

	return time / simulation.parameter.step_delta


class Data:
	var time: float
	var max_time: float

	var playing: bool = true:
		get:
			return playing
		set(value):
			playing = value
			_update_process()

	func _update_process():
		player_global.set_process(playing)
		#player_global.get_tree().call_group(NodeGroup.ANIMATABLE, &"set_process", playing)
