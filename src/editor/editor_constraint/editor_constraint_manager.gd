class_name EditorConstraintManager

signal action_requested(action: Callable)

var _content_group: EditorContentDataDB.Group
var _content_constraint_script: GDScript
var _content_id_constraint_dict: Dictionary
var _constrained_content_id_set = Set.new()


func _init(content_group: EditorContentDataDB.Group, content_constraint_script: GDScript, content_id_constraint_dict: Dictionary):
	_content_group = content_group
	_content_constraint_script = content_constraint_script
	_content_id_constraint_dict = content_id_constraint_dict

	content_group.contents_renewed.connect(_renew_content_constraints)
	content_group.content_added.connect(_add_content_constraint)


func _constraint_of(content_id: StringName):
	return _content_id_constraint_dict[content_id]


func _renew_content_constraints(contents: Array[ContentData]):
	for content_id in _constrained_content_id_set.to_array():
		_content_id_constraint_dict.erase(content_id)

	_constrained_content_id_set.clear()

	for content in contents:
		_add_content_constraint(content)


func _add_content_constraint(content: ContentData):
	if _content_id_constraint_dict.has(content.id):
		return

	var constraint = _content_constraint_script.new(content, _constraint_of, action_requested) as EditorContentConstraint
	_content_id_constraint_dict[content.id] = constraint
	_constrained_content_id_set.add(content.id)

	constraint.died.connect(_emit_remove_request.bind(content))
	constraint.revived.connect(_emit_add_request.bind(content))


func _emit_add_request(content: ContentData):
	var add = _add_content.bind(content)
	action_requested.emit(add)


func _emit_remove_request(content: ContentData):
	var remove = _remove_content.bind(content)
	action_requested.emit(remove)


func _add_content(content: ContentData):
	if _content_group.has_of(content.id):
		return

	_content_group.add(content)


func _remove_content(content: ContentData):
	if not _content_group.has_of(content.id):
		return

	_content_group.remove(content)
