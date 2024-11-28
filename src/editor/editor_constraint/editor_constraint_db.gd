class_name EditorConstraintDB

var _content_id_constraint_dict: Dictionary


func add(constraint: EditorContentConstraint):
	var content = constraint.data
	_content_id_constraint_dict[content.id] = constraint


func remove(constraint: EditorContentConstraint):
	var content = constraint.data
	_content_id_constraint_dict.erase(content.id)


func has_of(content_id: StringName) -> bool:
	return _content_id_constraint_dict.has(content_id)


func of(content_id: StringName) -> EditorContentConstraint:
	return _content_id_constraint_dict[content_id]
