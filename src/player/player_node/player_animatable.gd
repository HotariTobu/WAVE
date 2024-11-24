class_name PlayerAnimatable
extends Node2D


func _ready():
	add_to_group(NodeGroup.ANIMATABLE)
	set_process(false)


func _process(_delta):
	queue_redraw()
