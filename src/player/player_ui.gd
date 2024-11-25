extends CanvasLayer


func _ready():
	player_global.source.bind(&"time").to_slider(%SeekBar)
	player_global.source.bind(&"time").using(_num).to_label(%TimeLabel)
	player_global.source.bind(&"max_time").to(%SeekBar, &"max_value")
	player_global.source.bind(&"playing").to_texture_button(%PlayPauseButton)


static func _num(value: float) -> String:
	return str(value).pad_decimals(2)
