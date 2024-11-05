class_name BindingSourceDB

var _source_dict = {}

func get_or_add(object, notify_signal = 'notified') -> BindingSource:
	return _source_dict.get_or_add(object, BindingSource.new(object, notify_signal))
