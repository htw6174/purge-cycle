extends Node2D

class_name RoomController

export(float, 0.0, 1.0) var obstacle_density: float = 0.25
export(Array, NodePath) var door_paths: Array
export(Array, NodePath) var spawner_paths: Array

var is_hostile = true
var doors: Array # Array of Door
var spawners: Array # Array of Spawner

# Should be set when instancing
var level_position: Vector2

signal room_completed(room)
signal door_entered(room, direction)

func _ready():
	GameController.connect("room_changed", self, "_on_GameController_room_changed")
	doors.resize(door_paths.size())
	for i in doors.size():
		doors[i] = get_node(door_paths[i])
		doors[i].connect("entered", self, "_on_Door_entered", [i])
		# conditionally enabled and opened later
		doors[i].is_active = false
		doors[i].is_open = false
	spawners.resize(spawner_paths.size())
	for i in spawners.size():
		spawners[i] = get_node(spawner_paths[i])
		spawners[i].connect("spawning_finished", self, "_on_Spawner_spawning_finished")
		spawners[i].connect("all_spawned_are_dead", self, "_on_Spawner_all_spawned_are_dead")
	
	create_obstacles()

func get_entry_point(direction: int) -> Vector2:
	# position next to the door when entering FROM given direction
	return self.position + (Defs.direction_vectors[direction] * Vector2(-70, -35))

func activate_door(direction: int):
	doors[direction].is_active = true

func activate_room():
	# enable exit door colliders, start combat wave on first entry
	# doors are open if room is not hostile, or purge cycle is active
	for door in doors:
		door.is_open = (not is_hostile) or GameController.is_purge_active
	
	if GameController.is_purge_active:
		for spawner in spawners:
			spawner.start_spawn_repeating()
	elif is_hostile:
		for spawner in spawners:
			spawner.spawn_wave(0) # TODO: determine token budget for room
		for door in doors:
			door.close()

func deactivate_room():
	for door in doors:
		door.close()
	for spawner in spawners:
		spawner.stop_spawn_repeating()

func create_obstacles():
	for anchor in $Obstacles.get_children():
		if randf() < obstacle_density:
			var new_obstacle = ResourceLibrary.get_random_obstacle().instance()
			anchor.add_child(new_obstacle)

func _on_Door_entered(direction: int):
	emit_signal("door_entered", self, direction)

func _on_GameController_room_changed(room_exited, room_entered, direction):
	if room_exited == self:
		deactivate_room()
	if room_entered == self:
		activate_room()

func _on_Spawner_spawning_finished():
	pass

func _on_Spawner_all_spawned_are_dead():
	emit_signal("room_completed")
	is_hostile = false
	for door in doors:
		door.open()

# TODO: add support for variant wall art, random obstacles in each quadrant, random floor panelss
