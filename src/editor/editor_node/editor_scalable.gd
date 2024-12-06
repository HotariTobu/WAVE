class_name EditorScalable
extends EditorSelectable

@onready var _camera = get_viewport().get_camera_2d() as PanZoomCamera


func _ready():
	super()
	set_process(false)


func _process(_delta):
	queue_redraw()


func _draw():
	_scaled_draw(_camera.zoom_value)


func _scaled_draw(_drawing_scale: float) -> void:
	pass
