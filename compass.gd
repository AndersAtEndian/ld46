extends Node2D

func _ready():
	pass # Replace with function body.

func set_needle_rotation(deg: int):
	$needle.rotation = deg2rad(deg)
	
