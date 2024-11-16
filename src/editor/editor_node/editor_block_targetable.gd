class_name EditorBlockTargetable
extends EditorContent

var block_targeting: bool = false:
	get:
		return block_targeting
	set(value):
		block_targeting = value
		notified.emit(&"block_targeting")
		_on_property_updated()

var block_targeted: bool = false:
	get:
		return block_targeted
	set(value):
		block_targeted = value
		notified.emit(&"block_targeted")
		_on_property_updated()


func _update_process():
	super()
	set_process(is_processing() or block_targeting or block_targeted)


func _update_z_index():
	if block_targeting:
		z_index = 4
	elif block_targeted:
		z_index = 3
	else:
		super()
