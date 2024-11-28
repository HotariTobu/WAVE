class_name EditorTool
extends Node2D

@export var shortcut = Shortcut.new()


func get_id() -> StringName:
	var id = get_display_name().to_snake_case()
	return StringName(id)


func get_display_name() -> String:
	return "TOOL NAME"


func get_status_hint() -> String:
	return "TOOL HINT"


func activate() -> void:
	pass


func deactivate() -> void:
	queue_free()
