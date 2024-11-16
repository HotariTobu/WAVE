class_name ItemsToSourcesConverter
extends BindingConverter

var _editor_global = editor_global

var _content_node_script: GDScript


func _init(content_node_script: GDScript):
	_content_node_script = content_node_script


func source_to_target(source_value: Variant) -> Variant:
	var items = source_value as Array
	var sources: Array[EditorBindingSource] = []

	for item in items:
		if not _content_node_script.instance_has(item):
			continue

		var source = _editor_global.source_db.get_or_add(item.data)
		sources.append(source)

	return sources
