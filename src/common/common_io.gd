class_name CommonIO


static func read_data(path: String, script: GDScript) -> Result:
	assert(&"from_dict" in script)
	
	var result = Result.new()

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		result.error = FileAccess.get_open_error()
		return result

	var dict = file.get_var()
	file.close()

	if dict == null:
		result.error = ERR_PARSE_ERROR
		return result

	result.data = script.from_dict(dict)
	return result


static func write_data(path: String, script: GDScript, data: Variant) -> Result:
	assert(&"to_dict" in script)

	var result = Result.new()
	var dict = script.to_dict(data)

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		result.error = FileAccess.get_open_error()
		return result

	file.store_var(dict)
	file.close()

	return Result.new()


class Result:
	var error: Error = OK
	var data: Variant = null

	var ok: bool:
		get:
			return error == OK
