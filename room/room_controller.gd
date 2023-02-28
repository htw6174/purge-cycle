extends Node2D

class_name RoomController

export(Array, NodePath) var door_paths: Array

var is_exitable = true
var doors: Array # Array of Door

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
		doors[i].visible = false
		doors[i].is_open = false

func get_entry_point(direction: int) -> Vector2:
	# position next to the door when entering FROM given direction
	return self.position + (Defs.direction_vectors[direction] * Vector2(-70, -35))

func activate_door(direction: int):
	doors[direction].visible = true

func activate_room():
	# enable exit door colliders, start combat wave on first entry
	for door in doors:
		door.is_open = is_exitable

func deactivate_room():
	for door in doors:
		door.is_open = false

func _on_Door_entered(direction: int):
	emit_signal("door_entered", self, direction)

func _on_GameController_room_changed(room_exited, room_entered, direction):
	if room_exited == self:
		deactivate_room()
	if room_entered == self:
		activate_room()

# TODO: add support for variant wall art, random obstacles in each quadrant, random floor panelss
