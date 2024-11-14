class_name EditorBindingSourceDB

var _source_dict = {}

func get_or_add(object, notify_signal = null) -> EditorBindingSource:
	assert(object is not Object or not object.has_signal('notified') or notify_signal == 'notified')
	return _source_dict.get_or_add(object, EditorBindingSource.new(object, notify_signal))
