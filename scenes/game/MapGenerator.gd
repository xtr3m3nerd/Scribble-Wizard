class_name MapGenerator
extends Node3D

@export var wall_prefab: PackedScene
@export var enemy_prefab: PackedScene
@onready var player: Player = get_tree().get_first_node_in_group("player")


var map = []
var rows = 50
var columns = 50

var current_room_count = 0
var total_room_count = 10

var max_enemies_per_room = 3
var min_enemies_per_room = 1

var max_room_dim = 9
var min_room_dim = 4

var NOTHING = " "
var WALL = "X"
var FLOOR = "."
var DOOR = "D"
var CORNER = "Y"
var PLAYER = "P"

var ENEMIES = ["1", "2", "3"]

var wall_scale = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Prepopulate map as walls
	for x in range(rows):
		map.append([])
		for y in range(columns):
			map[x].append(NOTHING)
	
	# Randomly generate rooms
	var tries = 0
	while current_room_count < total_room_count and tries < 1000:
		current_room_count = current_room_count + room(bool(current_room_count == 0))
		tries = tries + 1
	
	draw_room()
	
	for x in range(columns):
		for y in range(rows):
			if map[x][y] == WALL or map[x][y] == CORNER:
				var wall = wall_prefab.instantiate()
				get_tree().current_scene.add_child.call_deferred(wall)
				wall.set_deferred("global_position", Vector3(x*wall_scale, 0, y*wall_scale))
			if map[x][y] == PLAYER:
				player.global_position = Vector3(x*wall_scale, 0, y*wall_scale)
			if ENEMIES.has(map[x][y]):
				var enemy = enemy_prefab.instantiate()
				get_tree().current_scene.add_child.call_deferred(enemy)
				enemy.set_deferred("global_position", Vector3(x*wall_scale, 0, y*wall_scale))

func draw_room():
	var map_str = ""
	for x in range(columns):
		for y in range(rows):
			map_str = map_str + map[x][y]
		map_str = map_str + "\n"
	print(map_str)
	
func room(is_player_room):
	var rng = RandomNumberGenerator.new()
	var width = rng.randf_range(min_room_dim, max_room_dim)
	var height = rng.randf_range(min_room_dim, max_room_dim)
	
	# Pick a random position for the room
	var position_x = rng.randf_range(4, columns - width - 4)
	var position_y = rng.randf_range(4, rows - height - 4)
	
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
	else:
		var enemy_count = rng.randf_range(min_enemies_per_room, max_enemies_per_room)
		for e_idx in range(enemy_count):
			while true:
				var x = rng.randf_range(position_x + 1, position_x + width - 1)
				var y = rng.randf_range(position_y + 1, position_y + height - 1)
				var e_type = ENEMIES[rng.randf_range(0, len(ENEMIES))]
				if map[x][y] == FLOOR:
					map[x][y] = e_type
					break
	
	return 1
	
	
