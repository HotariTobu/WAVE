extends Node

var _editor_global = editor_global


func _ready():
	for group in _editor_global.content_db.groups:
		var script = EditorScriptDict.constraint[group.name]
		var constraint_manager = EditorConstraintManager.new(group, script)
		add_child(constraint_manager)


func delete_selection():
	_editor_global.undo_redo.create_action("Delete selection")

	for content in _editor_global.selected_contents:
		var constraint = _editor_global.constraint_db.of(content.id)
		_editor_global.undo_redo.add_do_property(constraint, &"dead", true)
		_editor_global.undo_redo.add_undo_property(constraint, &"dead", false)

	_editor_global.undo_redo.commit_action()
