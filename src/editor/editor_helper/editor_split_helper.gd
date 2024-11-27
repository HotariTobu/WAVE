class_name EditorSplitHelper
extends EditorContentHelper


static func replace_id(content: ContentData, new_id_of: Callable) -> void:
	assert(content is SplitData)
	super(content, new_id_of)
	_replace_array_ids(&"block_target_ids", content, new_id_of)
