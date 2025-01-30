extends Container

var parameter: ParameterData:
	get:
		return parameter
	set(value):
		parameter = value
		_update_tabs_parameter()


func _update_tabs_parameter():
	for child in get_children():
		var tab = child.get_child(0)
		tab.parameter = parameter


func _on_child_entered_tree(node: Node) -> void:
	if node is LineEdit:
		node.select_all_on_focus = true
		node.text_submitted.connect(node.release_focus.unbind(1))

	elif node is Container:
		node.child_entered_tree.connect(_on_child_entered_tree)
