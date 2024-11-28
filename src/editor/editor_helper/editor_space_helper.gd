class_name EditorSpaceHelper
extends EditorSegmentsHelper


static func replace_id(content: ContentData, new_id_of: Callable) -> void:
	assert(content is SpaceData)
	super(content, new_id_of)
	_replace_array_ids(&"block_target_ids", content, new_id_of)
