extends CanvasLayer


func _ready():
	player_global.source.bind(&"time").to_slider(%SeekBar)
	player_global.source.bind(&"time").using(_num).to_label(%TimeLabel)
	player_global.source.bind(&"max_time").to(%SeekBar, &"max_value")
	player_global.source.bind(&"playing").to_texture_button(%PlayPauseButton)
	
	player_global.source.bind(&"property_dict").using(func(d): return JSON.stringify(d, "  ", false)).to_text_edit($TextEdit)
	player_global.source.bind(&"property_dict").using(func(d): return not d.is_empty()).to($TextEdit, &"visible")


static func _num(value: float) -> String:
	return str(value).pad_decimals(2)
