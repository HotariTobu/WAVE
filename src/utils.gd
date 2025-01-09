class_name Utils


static func is_descendant_of(script: Script, ancestor_script: Script):
	assert(ancestor_script != null)

	if script == null:
		return false

	if script == ancestor_script:
		return true

	var base_script = script.get_base_script()
	return is_descendant_of(base_script, ancestor_script)
