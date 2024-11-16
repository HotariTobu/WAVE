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
		if not isinstance(item, _content_node_script):
			continue

		var source = _editor_global.source_db.get_or_add(item.data)
		sources.append(source)

	return sources


static func isinstance(instance: Object, script: Script) -> bool:
	var instance_script = instance.get_script()
	while instance_script != null:
		if instance_script == script:
			return true

		instance_script = instance_script.get_base_script()

	return false
