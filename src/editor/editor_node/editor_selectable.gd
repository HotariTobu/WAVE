class_name EditorSelectable
extends Selectable

signal notified(property: StringName)

var data: ContentData:
	get:
		return _data

var _editor_global = editor_global

var _data: ContentData
var _source: EditorBindingSource


func _init(content: ContentData, layer: int):
	super(layer)
	z_as_relative = false
	unique_name_in_owner = true
	name = content.id

	_data = content
	_source = _editor_global.source_db.get_or_add(_data)


func _ready():
	_editor_global.set_content_node_owner(self)


func _on_selecting_changed():
	super()
	_update_z_index()
	notified.emit(&"selecting")


func _on_selected_changed():
	super()
	_update_z_index()
	notified.emit(&"selected")


func _update_z_index():
	if selecting:
		z_index = 2
	elif selected:
		z_index = 1
	else:
		z_index = 0


static func data_of(node: EditorSelectable) -> ContentData:
	return node._data
