extends ScrollContainer

var content_container: Node:
	get:
		return $PanelContainer/VBoxContainer/ContentContainer

var _editor_global = editor_global

var _property_content_dict: Dictionary
var _property_content: EditorPropertyPanelContent = null:
	get:
		return _property_content
	set(next):
		var prev = _property_content

		if prev != null:
			prev.deactivate.call_deferred()

		if next != null:
			next.activate.call_deferred()

		_property_content = next


func _ready():
	for child in content_container.get_children():
		var content = child as EditorPropertyPanelContent
		var type = content.get_target_content_type()
		assert(type != null)
		_property_content_dict[type] = content

	_editor_global.source.bind(&"selected_contents").using(_determine_property_content).to(self, &"_property_content")


func _determine_property_content(contents: Array[ContentData]):
	var len_contents = len(contents)
	if len_contents == 0:
		return null

	var type_of = func(object: Object): return object.get_script()
	var types = contents.map(type_of)

	var first_type = types.front()
	var same_type = func(type): return type == first_type

	if types.all(same_type):
		return _property_content_dict.get(first_type)

	return null
