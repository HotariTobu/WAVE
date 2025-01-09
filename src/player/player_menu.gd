extends MenuButton

@onready var _items = {
	"Dump...": %DumpDialog.show,
}

@onready var _popup = get_popup()


func _ready():
	for label in _items:
		_popup.add_item(label)

	_popup.index_pressed.connect(_on_index_pressed)


func _on_index_pressed(index: int):
	var label = _popup.get_item_text(index)
	var action = _items[label] as Callable
	action.call()


func _on_dump_dialog_dir_selected(dir):
	var result = Dumper.dump(dir, player_global.simulation)
	if result != OK:
		$ErrorDialog.show_error("An error occurred on dumping.", result)
