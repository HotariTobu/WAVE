class_name EditorStoplightHelper
extends EditorVertexHelper


static func replace_id(content: ContentData, new_id_of: Callable) -> void:
	assert(content is StoplightData)
	super(content, new_id_of)
	_replace_array_ids(&"split_ids", content, new_id_of)
