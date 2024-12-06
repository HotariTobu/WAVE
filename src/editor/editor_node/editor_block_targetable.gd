class_name EditorBlockTargetable
extends EditorSelectable

var block_targeting: bool = false:
	get:
		return block_targeting
	set(value):
		block_targeting = value
		notified.emit(&"block_targeting")
		_update_z_index()
		queue_redraw()

var block_targeted: bool = false:
	get:
		return block_targeted
	set(value):
		block_targeted = value
		notified.emit(&"block_targeted")
		_update_z_index()
		queue_redraw()


func _update_z_index():
	if block_targeting:
		z_index = 2
	elif block_targeted:
		z_index = 1
	else:
		super()
