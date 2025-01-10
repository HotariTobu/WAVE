class_name ContentsToFilteredSourcesConverter
extends BindingConverter

var _editor_global = editor_global

var _filter: Callable


func _init(filter: Callable):
	_filter = filter


func source_to_target(source_value: Variant) -> Variant:
	var contents = source_value as Array[ContentData]
	var filtered_contents = contents.filter(_filter)
	var sources = filtered_contents.map(_editor_global.source_db.get_or_add)
	return Array(sources, TYPE_OBJECT, &"RefCounted", EditorBindingSource)


static func from_type(target_content_type: GDScript) -> ContentsToFilteredSourcesConverter:
	var filter = is_instance_of.bind(target_content_type)
	return ContentsToFilteredSourcesConverter.new(filter)
