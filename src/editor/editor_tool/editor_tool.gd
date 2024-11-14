class_name EditorTool
extends Node2D

const PointerArea = preload("res://src/editor/editor_tool/pointer_area.tscn")

var _pointer_area = PointerArea.instantiate()

@export var shortcut = Shortcut.new()


func _init():
	add_child(_pointer_area)


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
