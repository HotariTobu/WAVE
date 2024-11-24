extends CanvasLayer


func _ready():
	player_global.data.bind(&"time").to_slider(%SeekBar)
	player_global.data.bind(&"time").using(_num).to_label(%TimeLabel)
	player_global.data.bind(&"max_time").to(%SeekBar, &"max_value")
	player_global.data.bind(&"playing").to_texture_button(%PlayPauseButton)


static func _num(value: float) -> String:
	return str(value).pad_decimals(2)
