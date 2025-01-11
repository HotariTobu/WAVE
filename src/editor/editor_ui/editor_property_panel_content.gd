class_name EditorPropertyPanelContent
extends GridContainer

const SIZE_NO_EXPAND = 0b10000

var source_proxy: BindingSourceProxy:
	get:
		return source_proxy
	set(next):
		var prev = source_proxy

		if prev != null:
			assert(not prev.sources.is_empty())
			_unbind_cells(prev)

		if next != null:
			assert(not next.sources.is_empty())
			_bind_cells(next)

		source_proxy = next

var _editor_global = editor_global


func _init():
	columns = 2
	hide()

	child_entered_tree.connect(_on_child_entered_tree)


func get_target_content_type() -> GDScript:
	return null


func activate() -> void:
	show()
	var converter = ContentsToFilteredSourcesConverter.from_type(get_target_content_type())
	_editor_global.source.bind(&"selected_contents").using(converter).using(_sources_to_proxy).to(self, &"source_proxy")


func deactivate() -> void:
	hide()
	_editor_global.source.unbind(&"selected_contents").from(self, &"source_proxy")
	source_proxy = null


func _bind_cells(_next_proxy: BindingSourceProxy) -> void:
	pass


func _unbind_cells(_prev_proxy: BindingSourceProxy) -> void:
	pass


func _on_child_entered_tree(node: Node) -> void:
	var control = node as Control
	if control == null:
		return

	if (control.size_flags_horizontal & SIZE_NO_EXPAND) == 0:
		control.size_flags_horizontal |= Control.SIZE_EXPAND

	if control is LineEdit:
		control.text_submitted.connect(_on_line_edit_text_submitted)
	elif control is Container:
		control.child_entered_tree.connect(_on_child_entered_tree)


func _on_line_edit_text_submitted(_new_text: String) -> void:
	get_viewport().gui_release_focus()


static func _sources_to_proxy(sources: Array[EditorBindingSource]) -> BindingSourceProxy:
	if sources.is_empty():
		return null

	var sources_for_proxy: Array[BindingSource]
	sources_for_proxy.assign(sources)
	return BindingSourceProxy.new(sources_for_proxy)
