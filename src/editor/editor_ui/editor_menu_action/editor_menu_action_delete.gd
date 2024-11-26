extends Node

var constraint_script_dict = {
	&"lane_vertices": EditorLaneVertexConstraint,
	&"lanes": EditorLaneConstraint,
	&"splits": EditorSplitConstraint,
	&"stoplights": EditorStoplightConstraint,
}

var _editor_global = editor_global

var _content_id_constraint_dict: Dictionary
var _constrain_managers: Array[EditorConstraintManager]


func _init():
	constraint_script_dict.make_read_only()


func _ready():
	for group in _editor_global.content_db.groups:
		var script = constraint_script_dict[group.name]
		var constraint_manager = EditorConstraintManager.new(group, script, _content_id_constraint_dict)
		var action_queue = ActionQueue.new()
		constraint_manager.action_requested.connect(action_queue.push)
		_constrain_managers.append(constraint_manager)
		add_child(action_queue)


func delete_selection():
	_editor_global.undo_redo.create_action("Delete selection")

	for content in _editor_global.data.selected_contents:
		var constraint = _content_id_constraint_dict[content.id] as EditorConstraint
		_editor_global.undo_redo.add_do_property(constraint, &"dead", true)
		_editor_global.undo_redo.add_undo_property(constraint, &"dead", false)

	_editor_global.undo_redo.commit_action()
