class_name EditorContent
extends EditorSelectable

var data: ContentData:
	get:
		return _data

var _editor_global = editor_global

var _data: ContentData
var _source: EditorBindingSource


func _init(content: ContentData, layer: int):
	super(layer)
	unique_name_in_owner = true
	name = content.id

	_data = content


func _ready():
	super()
	owner = get_tree().root

	_source = _editor_global.source_db.get_or_add(_data)


static func data_of(node: EditorContent) -> ContentData:
	return node._data