extends ScrollContainer

var _editor_global = editor_global

var _property_contents: Array[EditorPropertyPanelContent]
var _activated_property_content_set = ObservableSet.new()


func _ready():
	_property_contents.assign(%ContentContainer.get_children())
	_activated_property_content_set.value_added.connect(_on_active_property_content_added)
	_activated_property_content_set.value_removed.connect(_on_active_property_content_removed)

	_editor_global.source.add_callback(&"selected_contents", _on_selected_contents_changed)


func _on_selected_contents_changed():
	var contents = _editor_global.selected_contents
	if contents.is_empty():
		_activated_property_content_set.clear()
		return

	var first_content = contents.front() as ContentData
	var first_type = first_content.get_script() as GDScript

	for content in contents:
		var type = content.get_script()
		if first_type == type:
			continue

		_activated_property_content_set.clear()
		return

	for property_content in _property_contents:
		var type = property_content.get_target_content_type()

		if _is_descendant_of(first_type, type):
			_activated_property_content_set.add(property_content)

		elif _activated_property_content_set.has(property_content):
			_activated_property_content_set.erase(property_content)


func _on_active_property_content_added(property_content: EditorPropertyPanelContent):
	property_content.activate.call_deferred()


func _on_active_property_content_removed(property_content: EditorPropertyPanelContent):
	property_content.deactivate.call_deferred()


static func _is_descendant_of(script: Script, ancestor_script: Script):
	assert(ancestor_script != null)

	if script == null:
		return false

	if script == ancestor_script:
		return true

	var base_script = script.get_base_script()
	return _is_descendant_of(base_script, ancestor_script)
