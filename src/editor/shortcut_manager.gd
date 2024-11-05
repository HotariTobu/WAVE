class_name ShortcutManager
extends Control

signal handled(targets: Array[Variant])

var _shortcut_map = {}


func _shortcut_input(event):
	var event_name = ShortcutManager._get_event_name(event)
	var targets = _shortcut_map.get(event_name)
	if targets == null:
		return

	handled.emit(targets)
	accept_event()


func add_shortcut(shortcut: Shortcut, target: Variant):
	for event_name in ShortcutManager._get_shortcut_event_names(shortcut):
		var targets = _shortcut_map.get_or_add(event_name, [])
		targets.append(target)


func clear_shortcuts():
	_shortcut_map.clear()


static func _get_shortcut_event_names(shortcut: Shortcut):
	return shortcut.events.map(_get_event_name)


static func _get_event_name(event: InputEvent):
	return StringName(str(event))
