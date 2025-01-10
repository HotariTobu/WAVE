extends ColorRect

var _editor_global = editor_global

static var _base_color: Color = ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color")


func _ready():
	_editor_global.source.bind(&"opacity").using(_get_color).to_color_rect(self)


static func _get_color(opacity: float) -> Color:
	return Color(_base_color, opacity)
