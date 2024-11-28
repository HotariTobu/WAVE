class_name EditorConstraintManager
extends ActionQueue

var _editor_global = editor_global

var _content_group: EditorContentDataDB.Group
var _content_constraint_script: GDScript
var _constraints: Array[EditorContentConstraint]


func _init(content_group: EditorContentDataDB.Group, content_constraint_script: GDScript):
	_content_group = content_group
	_content_constraint_script = content_constraint_script

	content_group.contents_renewed.connect(_renew_content_constraints)
	content_group.content_added.connect(_add_content_constraint)


func _renew_content_constraints(contents: Array[ContentData]):
	for constraint in _constraints:
		_editor_global.constraint_db.remove(constraint)

	_constraints.clear()

	for content in contents:
		_add_content_constraint(content)


func _add_content_constraint(content: ContentData):
	if _editor_global.constraint_db.has_of(content.id):
		return

	var constraint = _content_constraint_script.new(content) as EditorContentConstraint
	_editor_global.constraint_db.add(constraint)
	_constraints.append(constraint)

	constraint.action_requested.connect(push)

	constraint.died.connect(push.bind(_remove_content.bind(content)))
	constraint.revived.connect(push.bind(_add_content.bind(content)))


func _add_content(content: ContentData):
	if _content_group.has_of(content.id):
		return

	_content_group.add(content)


func _remove_content(content: ContentData):
	if not _content_group.has_of(content.id):
		return

	_content_group.remove(content)
