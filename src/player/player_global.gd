extends Node

var source = EditorBindingSource.new(self)

var simulation: SimulationData

var content_db: PlayerContentDataDB

var time: float
var max_time: float

var exact_step: float
var step_frac: float
var prev_step: int
var next_step: int

var property_dict: Dictionary

var playing: bool = true:
	get:
		return playing
	set(value):
		playing = value
		_update_process()

		if value and time == max_time:
			source.time = 0


func _ready():
	source.add_callback(&"simulation", _reset)
	source.add_callback(&"time", _update_step)


func _process(delta):
	source.time = time + delta

	if time > max_time:
		source.set_deferred(&"time", max_time)
		source.set_deferred(&"playing", false)


func _reset():
	content_db = PlayerContentDataDB.new(simulation.network)

	source.time = 0.0
	source.max_time = simulation.parameter.max_step * simulation.parameter.step_delta
	source.playing = false


func _update_step():
	if simulation == null:
		return

	exact_step = time / simulation.parameter.step_delta
	step_frac = fmod(exact_step, 1.0)
	prev_step = floori(exact_step)
	next_step = ceili(exact_step)
	if prev_step == next_step:
		next_step += 1


func _update_process():
	set_process(playing)
	#get_tree().call_group(NodeGroup.ANIMATABLE, &"set_process", playing)
