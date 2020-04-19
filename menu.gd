extends Node2D

var my_font

func _ready():
	my_font = make_font(24)

func make_font(font_size: int):
	var font := DynamicFont.new()
	font.size = font_size
	font.set_font_data(load("res://assets/Retro Gaming.ttf"))
	return font

func _draw():
	draw_rect(Rect2(32.0, 26.0, 300.0, 256.0), Color(0.3, 0.3, 0.3), true)
	draw_string(my_font, Vector2(48, 64), "1 Pilot", Color(1.0, 1.0, 1.0)) 
	draw_string(my_font, Vector2(48, 96), "2 Navigator", Color(1.0, 1.0, 1.0)) 
	draw_string(my_font, Vector2(48, 128), "3 Radio", Color(1.0, 1.0, 1.0)) 
	draw_string(my_font, Vector2(48, 160), "4 Nose Gunner", Color(1.0, 1.0, 1.0)) 
	draw_string(my_font, Vector2(48, 192), "5 Tail Gunner", Color(1.0, 1.0, 1.0)) 
	draw_string(my_font, Vector2(48, 224), "6 Repairman", Color(1.0, 1.0, 1.0)) 
	draw_string(my_font, Vector2(48, 256), "7 Bomb Dropper", Color(1.0, 1.0, 1.0)) 
	
