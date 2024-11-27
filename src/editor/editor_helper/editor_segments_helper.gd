class_name EditorSegmentsHelper
extends EditorContentHelper


static func replace_id(content: ContentData, new_id_of: Callable) -> void:
	assert(content is SegmentsData)
	super(content, new_id_of)
	_replace_array_ids(&"vertex_ids", content, new_id_of)
