class_name EditorBridgeHelper
extends EditorSpaceHelper


static func replace_id(content: ContentData, new_id_of: Callable) -> void:
	assert(content is BridgeData)
	super(content, new_id_of)
	_replace_dict_ids(&"prev_option_dict", content, new_id_of)
	_replace_dict_ids(&"next_option_dict", content, new_id_of)
