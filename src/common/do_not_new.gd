class_name DoNotNew

static var _new_allowed = false


func _init():
	assert(_new_allowed, "The class is not allowed to instantiate manually.")


static func _new(script: GDScript):
	assert(Utils.is_descendant_of(script, DoNotNew))
	assert(script._update_new_allowed(true))
	var instance = script.new()
	assert(script._update_new_allowed(false))
	return instance


static func _update_new_allowed(value: bool) -> bool:
	_new_allowed = value
	return true
