extends ScrollContainer

var content_container: Node:
	get:
		return $PanelContainer/VBoxContainer/ContentContainer

var _editor_global = editor_global

var _property_content_map = {}
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
		var type = content.get_target_type()
		_property_content_map[type] = content

	_editor_global.data.bind(&'selected_items').using(_determine_property_content).to(self, &'_property_content')

func _determine_property_content(items: Array[EditorSelectable]):
	var len_items = len(items)
	if len_items == 0:
		return null

	var first_item = items.front() as EditorSelectable
	var first_type = first_item.get_script()

	for index in range(1, len_items):
		var item = items[index] as EditorSelectable
		var type = item.get_script()
		if first_type == type:
			continue

		return null

	return _property_content_map.get(first_type)
