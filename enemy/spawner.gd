extends Node2D

class_name Spawner

export(bool) var spawn_repeating: bool = false
export(float) var spawn_interval: float = 1.0
export(PackedScene) var enemy_scene: PackedScene

var wave_enemies: Array
var wave_spawn_index: int = 0
var died_count: int = 0

signal spawning_started()
signal spawning_finished()
signal all_spawned_are_dead()

func _ready():
	pass

func spawn_wave(tokens: int):
	# check if wave is in progress
	if not $Timer.is_stopped():
		return
	# setup
	var is_elite = (randi() % 2) as bool
	var wave_budget: int = tokens
	var count_to_spawn: int
	if is_elite:
		count_to_spawn = (randi() % 3) + 1 # 1-3
	else:
		count_to_spawn = Defs.WAVE_MAX_SIZE
	# determine preset mix
	wave_enemies = []
	while count_to_spawn > 0:
		var enemy_budget: int = int(wave_budget / count_to_spawn)
		var preset = ResourceLibrary.get_random_enemy_preset(enemy_budget)
		wave_enemies.append(preset)
		count_to_spawn -= 1
		wave_budget -= preset.hazard # could be less than budgeted cost
	wave_enemies.shuffle()
	# start timer
	wave_spawn_index = 0
	died_count = 0
	$Timer.wait_time = spawn_interval
	$Timer.start()
	emit_signal("spawning_started")

func start_spawn_repeating():
	spawn_repeating = true
	$Timer.start()
	emit_signal("spawning_started")

func stop_spawn_repeating():
	spawn_repeating = false
	$Timer.stop()
	emit_signal("spawning_finished")

func spawn_enemy(preset: EnemyPreset):
	var new_enemy = enemy_scene.instance() as Enemy
	new_enemy.preset = preset
	new_enemy.connect("died", self, "_on_Enemy_died")
	new_enemy.visible = false
	self.add_child(new_enemy)

func spawn_next():
	if wave_spawn_index < wave_enemies.size():
		spawn_enemy(wave_enemies[wave_spawn_index])
		wave_spawn_index += 1
	if wave_spawn_index >= wave_enemies.size():
		$Timer.stop()
		emit_signal("spawning_finished")

func spawn_random():
	spawn_enemy(ResourceLibrary.get_random_enemy_preset())

func _on_Timer_timeout():
	if spawn_repeating:
		spawn_random()
	else:
		spawn_next()

func _on_Enemy_died():
	died_count += 1
	if died_count == wave_enemies.size():
		emit_signal("all_spawned_are_dead")
