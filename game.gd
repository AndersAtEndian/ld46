extends Node2D

var pixels_per_second_landmarks := 100
var pixels_per_second_clouds := 300
var next_cloud_timeout := 0.0
var plane_direction_deg := 0.0
var plane_direction_target_deg := 0.0
var plane_direction_frame_change := 3.0

var plane_turn := 0.0

var cloud_generator_scene = preload("res://cloud-generator.tscn")
var cloud_generator = null

var land_water_percentage := 66.0

var neighbor_direction = [Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), 
	Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0)]
var tile_directions = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]

enum TILES {GRASS, WATER, 
	GRASS_CORNER_0, GRASS_CORNER_1, GRASS_CORNER_2, GRASS_CORNER_3,
	GRASS_SIDE_0, GRASS_SIDE_1, GRASS_SIDE_2, GRASS_SIDE_3, 
	GRASS_CORRIDOR_0, GRASS_CORRIDOR_1, GRASS_CORRIDOR_2, GRASS_CORRIDOR_3, 
	GRASS_TIP_0, GRASS_TIP_1, GRASS_TIP_2, GRASS_TIP_3,
	GRASS_ISLAND}
	
enum GAME_STATE {IDLE, PILOT, NAVIGATOR, NOSE_GUNNER, TAIL_GUNNER, REPAIRMAN, BOMB_DROPPER}
var game_state = GAME_STATE.IDLE

func _ready():
	randomize()
	create_map()
	cloud_generator = cloud_generator_scene.instance()

func _process(delta):
	next_cloud_timeout -= delta
	if next_cloud_timeout < 0.0:
		next_cloud_timeout = rand_range(0.2, 1.0)
		var cloud = cloud_generator.get_random_cloud()
		var cloud_position = $bomber.position + Vector2(rand_range(-1024.0, 0.0), -1500.0)
		print("new cloud {0}".format([cloud_position]))
		cloud.position = cloud_position
		$pivot/clouds.add_child(cloud)
		
	if Input.is_action_just_pressed("ui_right"):
		plane_direction_target_deg -= 5.0
	if Input.is_action_just_pressed("ui_left"):
		plane_direction_target_deg += 5.0

		
	if game_state == GAME_STATE.IDLE:
		if Input.is_key_pressed(KEY_1):
			game_state = GAME_STATE.PILOT
			$bomber/cockpit.visible = true
		if Input.is_key_pressed(KEY_2):
			game_state = GAME_STATE.NAVIGATOR
			$bomber/map.visible = true

	if game_state == GAME_STATE.PILOT:
		if Input.is_action_just_pressed("ui_right"):
			plane_turn += 1
		if Input.is_action_just_pressed("ui_left"):
			plane_turn -= 1
			
		if plane_turn < -2:
			plane_turn = -2
		elif plane_turn > 2:
			plane_turn = 2
			
		$bomber/cockpit/pivot.set_rotation(deg2rad(15 * plane_turn))

	if Input.is_action_just_pressed("ui_cancel"):
		$bomber/cockpit.visible = false
		$bomber/map.visible = false
		game_state = GAME_STATE.IDLE
		
	plane_direction_deg += delta * plane_direction_frame_change * plane_turn
		
	$bomber.rotation = deg2rad(plane_direction_deg)
	
	$bomber/compass.set_needle_rotation(plane_direction_deg)
	
	var forward_direction := Vector2(sin(deg2rad(plane_direction_deg)), -1 * cos(deg2rad(plane_direction_deg)))
	
	#$bomber.position -= forward_direction * delta * pixels_per_second_landmarks
	$bomber.move_and_slide(forward_direction * 100)
	
	for cloud in $pivot/clouds.get_children():
		if cloud.is_visible():
			cloud.has_been_visible = true
		elif cloud.has_been_visible:
			$pivot/clouds.remove_child(cloud)
		cloud.position.y += delta * 100
	
	
func create_map():

	var nr_grass := 0
	var nr_water := 0
	
	for y in range(-302, 22):
		for x in range(-152, 152):
			var num = rand_range(0.0, 100.0)
			if num < land_water_percentage:
				$pivot/tile_map.set_cell(x, y, TILES.WATER)
			else:
				$pivot/tile_map.set_cell(x, y, TILES.GRASS)
				
	for y in range(-300, 20):
		for x in range(-150, 150):
			var number_of_neighbor_water := 0
			for direction in neighbor_direction:
				var current_tile = Vector2(x, y) + direction
				if $pivot/tile_map.get_cell(current_tile.x, current_tile.y) == TILES.WATER:
					number_of_neighbor_water += 1
			if number_of_neighbor_water > 4:
				$pivot/tile_map.set_cell(x, y, TILES.WATER)
			else:	
				$pivot/tile_map.set_cell(x, y, TILES.GRASS)
				
	for y in range(-300, 20):
		for x in range(-150, 150):
			if $pivot/tile_map.get_cell(x, y) != TILES.WATER:
				var bit_value := 1
				var neighbor_value := 0
				for direction in tile_directions:
					var current_tile = Vector2(x, y) + direction
					if $pivot/tile_map.get_cell(current_tile.x, current_tile.y) != TILES.WATER:
						neighbor_value += bit_value
					bit_value <<= 1

				if neighbor_value == 0b0110:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_CORNER_0)
				elif neighbor_value == 0b1100:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_CORNER_1)
				elif neighbor_value == 0b1001:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_CORNER_2)
				elif neighbor_value == 0b0011:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_CORNER_3)
				elif neighbor_value == 0b0111:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_SIDE_0)
				elif neighbor_value == 0b1110:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_SIDE_1)
				elif neighbor_value == 0b1101:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_SIDE_2)
				elif neighbor_value == 0b1011:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_SIDE_3)
				elif neighbor_value == 0b0101:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_CORRIDOR_0)
				elif neighbor_value == 0b1010:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_CORRIDOR_1)
				elif neighbor_value == 0b0010:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_TIP_0)
				elif neighbor_value == 0b0100:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_TIP_1)
				elif neighbor_value == 0b1000:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_TIP_2)
				elif neighbor_value == 0b0001:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_TIP_3)
				elif neighbor_value == 0b0000:
					$pivot/tile_map.set_cell(x, y, TILES.GRASS_ISLAND)
	
	var img = Image.new()
	img.create(400, 400, false, Image.FORMAT_RGBA8)
	img.lock()
	
	for y in range(-300, 20):
		for x in range(-150, 150):
			var map_x := x + 200
			var map_y := y + 350
			if $pivot/tile_map.get_cell(x, y) == TILES.WATER:
				img.set_pixel(map_x, map_y, Color(0.16, 0.80, 0.87, 1.0))
			else:
				img.set_pixel(map_x, map_y, Color(0.22, 0.48, 0.27, 1.0))	
				
	img.unlock()
	
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(img)
	$bomber/map/sprite_map.texture = image_texture
	
	
	
	
