class_name EditorPropertyPanelContent
extends GridContainer

const SIZE_NO_EXPAND = 0b10000


func _init():
	columns = 2
	hide()

	child_entered_tree.connect(_on_child_entered_tree)


func get_target_type() -> Script:
	return null


func activate():
	show()


func deactivate():
	hide()


func _on_child_entered_tree(node: Node):
	var control = node as Control
	if control == null:
		return

	if (control.size_flags_horizontal & SIZE_NO_EXPAND) == 0:
		control.size_flags_horizontal |= Control.SIZE_EXPAND

	if control is LineEdit:
		control.text_submitted.connect(_on_line_edit_text_submitted)
	elif control is Container:
		control.child_entered_tree.connect(_on_child_entered_tree)


func _on_line_edit_text_submitted(_new_text: String):
	get_viewport().gui_release_focus()
