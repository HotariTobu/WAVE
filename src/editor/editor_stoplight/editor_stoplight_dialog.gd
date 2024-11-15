extends ConfirmationDialog

var stoplight: EditorStoplightData:
	get:
		return stoplight
	set(value):
		stoplight = value
		var source = _editor_global.source_db.get_or_add(value, &'notified')
		_property_panel_content.stoplight_sources = [source] as Array[EditorBindingSource]

var _editor_global = editor_global

@onready var _property_panel_content = $ScrollContainer/PropertyPanelContent

func _ready():
	_property_panel_content.get_child(0).queue_free()
	_property_panel_content.get_child(1).queue_free()
	_property_panel_content.show()
