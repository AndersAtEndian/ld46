extends Node2D

export(Texture) var texture

var has_been_visible := false

# Called when the node enters the scene tree for the first time.
func _ready():
	$sprite.texture = texture

func cloud_flip(should_i_flip: bool):
	$sprite.set_flip_h(should_i_flip)
	
func cloud_rotation(deg: int):
	$sprite.rotation = deg2rad(deg)
