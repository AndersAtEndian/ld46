extends Node2D

func _ready():
	pass # Replace with function body.

func get_random_landmark():
	
	var landmark_idx := randi() % ($templates.get_children().size())
	
	var landmark_instance := $templates.get_child(landmark_idx).duplicate()
	landmark_instance.position = Vector2(0, 0)
	return landmark_instance
	
