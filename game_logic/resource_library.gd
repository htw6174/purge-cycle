extends Node

var enemy_presets_directory: String = "res://enemy/presets/"
var enemy_presets: Array # Array of EnemyPreset

var obstacles_directory: String = "res://room/obstacles/"
var obstacles: Array # Array of PackedScene

func _ready():
	load_enemy_presets()
	load_obstacles()

func load_resources_in_directory(directory: String, extension: String) -> Array:
	var results: Array = []
	var dir = Directory.new()
	if dir.open(directory) == OK:
		dir.list_dir_begin(true, true)
		var filename: String = dir.get_next()
		while filename != "":
			# load file if extension matches
			if filename.ends_with("." + extension):
				results.append(load(directory + filename))
			filename = dir.get_next()
	return results

func load_enemy_presets():
	enemy_presets = load_resources_in_directory(enemy_presets_directory, "tres")

func load_obstacles():
	obstacles = load_resources_in_directory(obstacles_directory, "tscn")

# pir = price is right: will try to get as close as possible to the cost without going over. -1 will ignore cost
func get_random_enemy_preset(pir_cost: int = -1) -> EnemyPreset:
	return enemy_presets[randi() % enemy_presets.size()]

func get_random_obstacle() -> PackedScene:
	return obstacles[randi() % obstacles.size()]

