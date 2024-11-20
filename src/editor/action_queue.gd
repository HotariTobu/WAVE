class_name ActionQueue
extends Node

var _actions: Array[Callable]


func _ready():
	set_process(false)


func _process(_delta):
	for action in _actions:
		action.call()

	_actions.clear()
	set_process(false)


func push(action: Callable):
	assert(not _actions.has(action))
	_actions.append(action)
	set_process(true)
