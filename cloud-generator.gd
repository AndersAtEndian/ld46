extends Node2D

func _ready():
	pass # Replace with function body.

func get_random_cloud():
	
	var cloud_idx := randi() % ($templates.get_children().size())
	
	var cloud_instance := $templates.get_child(cloud_idx).duplicate()
	cloud_instance.position = Vector2(0, 0)
	
	var flip = randi() % 2
	cloud_instance.cloud_flip(flip == 1)
	cloud_instance.cloud_rotation(rand_range(-15.0, 15.0))
	return cloud_instance
