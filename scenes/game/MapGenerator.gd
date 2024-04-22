class_name MapGenerator
extends Node3D

@export var wall_prefab: PackedScene
@export var floor_prefab: PackedScene
@export var stairs_prefab: PackedScene
@onready var player: Player = get_tree().get_first_node_in_group("player")


var map = []

var current_room_count = 0
var level_data: DungeonLevel = null
var spawn_count: Dictionary = {}

var NOTHING = " "
var WALL = "X"
var FLOOR = "."
var DOOR = "D"
var CORNER = "Y"
var PLAYER = "P"
var STAIRS = "S"

var wall_scale = 2

func clear_map():
	spawn_count = {}
	map = []
	for x in range(level_data.rows()):
		map.append([])
		for y in range(level_data.columns()):
			map[x].append(NOTHING)
	for child in get_children():
		child.queue_free()
		
# Called when the node enters the scene tree for the first time.
func generate_level(p_level_data: DungeonLevel):
	
	level_data = p_level_data
	clear_map()
	
	# Randomly generate rooms
	var tries = 0
	while current_room_count < level_data.total_room_count:
		current_room_count = current_room_count + room(bool(current_room_count == 0), bool(current_room_count == level_data.total_room_count -1))
		tries = tries + 1
		# If we can't generate a map in 10000 tries, simply reset since the existing rooms are in a wierd position.
		if tries > level_data.total_room_count * 10000:
			print("Failed to generate map")
			clear_map()
			current_room_count = 0
			tries = 0
	
	draw_room()
	
	for x in range(level_data.columns()):
		for y in range(level_data.rows()):
			if map[x][y] != NOTHING and map[x][y] != STAIRS:
				var floor = floor_prefab.instantiate()
				add_child.call_deferred(floor)
				floor.set_deferred("global_position", Vector3(x*wall_scale, 0, y*wall_scale))
			if map[x][y] == STAIRS:
				var stairs = stairs_prefab.instantiate()
				add_child.call_deferred(stairs)
				stairs.set_deferred("global_position", Vector3(x*wall_scale, 0, y*wall_scale))
			if map[x][y] == WALL or map[x][y] == CORNER:
				var wall = wall_prefab.instantiate()
				add_child.call_deferred(wall)
				wall.set_deferred("global_position", Vector3(x*wall_scale, 0, y*wall_scale))
			if map[x][y] == PLAYER:
				player.global_position = Vector3(x*wall_scale, 0, y*wall_scale)
			if map[x][y].is_valid_int():
				var index = int(map[x][y])
				var enemy = level_data.spawn_table[index].prefab.instantiate()
				add_child.call_deferred(enemy)
				enemy.set_deferred("global_position", Vector3(x*wall_scale, 0, y*wall_scale))

func draw_room():
	var map_str = ""
	for x in range(level_data.columns()):
		for y in range(level_data.rows()):
			map_str = map_str + map[x][y]
		map_str = map_str + "\n"
	print(map_str)
	
func room(is_player_room, is_last_room):
	var rng = RandomNumberGenerator.new()
	var width = rng.randf_range(level_data.min_room_dim, level_data.max_room_dim)
	var height = rng.randf_range(level_data.min_room_dim, level_data.max_room_dim)
	
	# Pick a random position for the room
	var position_x = rng.randf_range(4, level_data.columns() - width - 4)
	var position_y = rng.randf_range(4, level_data.rows() - height - 4)
	
	# Return early if there is any overlap with another room
	for x in range(position_x+1, position_x + width + 1):
		for y in range(position_y+1, position_y + height + 1):
			if (map[x][y] != NOTHING):
				return 0
	
	# Return early if the room doesn't have a neighboring room
	var door_x = 0
	var door_y = 0
	if current_room_count > 0:
		var has_adjacent_room = false
		for x in range(position_x, position_x + width):
			for y in range(position_y, position_y + height):
				var is_vertical_wall = x < position_x || x > position_x + width
				var is_horizontal_wall = y < position_y || y > position_y + height
				if map[x][y] == WALL and not (is_vertical_wall and is_horizontal_wall):
					has_adjacent_room = true
					door_x = x
					door_y = y
		if not has_adjacent_room:
			return 0
	
	
	# Draw the room
	for x in range(position_x, position_x + width + 2):
		for y in range(position_y, position_y + height + 2):
			var is_vertical_wall = x < position_x || x > position_x + width
			var is_horizontal_wall = y < position_y || y > position_y + height
			if is_horizontal_wall or is_vertical_wall:
				if is_horizontal_wall and is_vertical_wall:
					map[x][y] = CORNER
				else:
					map[x][y] = WALL
			else:
				map[x][y] = FLOOR
	map[door_x][door_y] = DOOR
	
	# Place Enemies or Player
	if is_player_room:
		while true:
			var x = rng.randf_range(position_x + 1, position_x + width - 1)
			var y = rng.randf_range(position_y + 1, position_y + height - 1)
			if map[x][y] == FLOOR:
				map[x][y] = PLAYER
				break
	elif is_last_room:
		while true:
			var x = rng.randf_range(position_x + 1, position_x + width - 1)
			var y = rng.randf_range(position_y + 1, position_y + height - 1)
			if map[x][y] == FLOOR:
				map[x][y] = STAIRS
				break
	else:
		var enemy_count = rng.randf_range(level_data.min_enemies_per_room, level_data.max_enemies_per_room)
		for e_idx in range(enemy_count):
			while true:
				var x = rng.randf_range(position_x + 1, position_x + width - 1)
				var y = rng.randf_range(position_y + 1, position_y + height - 1)
				var enemy_index = level_data.pick_from_spawn_table(rng)
				if enemy_index == -1:
					continue
				if map[x][y] == FLOOR:
					var spawn_weight = level_data.spawn_table[enemy_index]
					if !spawn_count.has(spawn_weight):
						spawn_count[spawn_weight] = 0
					
					if spawn_weight.max_amt != -1:
						if spawn_count[spawn_weight] >= spawn_weight.max_amt:
							continue
					var e_type = str(enemy_index)
					map[x][y] = e_type
					spawn_count[spawn_weight] += 1
					break
	
	return 1
	
	
