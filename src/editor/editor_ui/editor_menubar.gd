extends Control

var _editor_global = editor_global

@onready var _menus: Array[EditorMenuButton] = [
	EditorMenuButton.new('File', [
		EditorMenuItem.new('Open Network...', $ReadWrite.open_network, &'ui_open'),
		EditorMenuItem.new('Save Network', $ReadWrite.save_network, &'ui_save'),
		EditorMenuItem.new('Save Network as...', $ReadWrite.save_network_as, &'ui_save_as'),
	]),
	EditorMenuButton.new('Edit', [
		EditorMenuItem.new('Undo', _editor_global.undo_redo.undo, &'ui_undo'),
		EditorMenuItem.new('Redo', _editor_global.undo_redo.redo, &'ui_redo'),
		EditorMenuItem.new('Delete', $Delete.delete_selection, &'ui_text_delete'),
	]),
	EditorMenuButton.new('Simulation', [
		EditorMenuItem.new('Run...', $Simulation.open_simulator_window),
	]),
]

var _just_closed = false

func _ready():
	for menu in _menus:
		$Container.add_child(menu)
		menu.toggled.connect(_on_menu_button_toggled)
		menu.get_popup().id_pressed.connect(_on_menu_item_pressed)

func _input(event):
	if not _just_closed:
		return

	get_viewport().set_input_as_handled()

	if (event is InputEventMouseButton and not event.pressed) or event.is_action(&"ui_cancel"):
		_reset_input_filter()

func _on_menu_button_toggled(toggled_on: bool):
	if toggled_on:
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		_just_closed = true

func _on_menu_item_pressed(_id: int):
	_reset_input_filter()

func _reset_input_filter():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_just_closed = false

class EditorMenuButton extends MenuButton:
	var items: Array[EditorMenuItem]

	func _init(_label: String, _items: Array[EditorMenuItem]):
		text = _label
		items = _items

	func _ready():
		var popup = get_popup()

		for id in range(len(items)):
			var item = items[id]
			popup.add_item(item.label, id)
			popup.set_item_shortcut(id, item.shortcut)

		popup.id_pressed.connect(_on_id_pressed)

	func _on_id_pressed(id: int):
		items[id].action.call()

class EditorMenuItem:
	var label: String
	var action: Callable

	var shortcut = Shortcut.new()

	func _init(_label: String, _action: Callable, _action_name = &''):
		label = _label
		action = _action

		var shortcut_event = InputEventAction.new()
		shortcut_event.action = _action_name
		shortcut.events.append(shortcut_event)
