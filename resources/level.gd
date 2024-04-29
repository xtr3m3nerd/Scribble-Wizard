class_name DungeonLevel
extends  Resource

enum Rune {
	NONE,
	WATER,
	LIGHTNING,
	FIRE,
	WATER_WITH_LIGHTNING,
	PUSH,
	TRAP
}

@export var shown_rune: Rune
@export var total_room_count = 4

@export var max_room_dim = 9
@export var min_room_dim = 4

@export var max_enemies_per_room = 3
@export var min_enemies_per_room = 1
 
@export var spawn_table: Array[SpawnWeight] = []

@export var boss_monster: PackedScene = null

func rows() -> int:
	return int(max_room_dim*total_room_count*1.5)
func columns() -> int:
	return int(max_room_dim*total_room_count*1.5)

func pick_from_spawn_table(rng: RandomNumberGenerator) -> int:
	var total_weight = 0.0
	for spawn in spawn_table:
		total_weight += spawn.weight
	
	var roll = rng.randf_range(0.0, total_weight)
	
	var weight_count = 0.0
	var index = -1
	for spawn in spawn_table:
		index += 1
		weight_count += spawn.weight
		if weight_count > roll:
			return index
	
	return index
