# This is an autoload class
# The goal of this class is to allow for loose coupling by providing a central place for other nodes 
# to report 'game-wide' events to, and connect to signals representing other significant gameplay events,
# similar to GDQuest's 'Event Bus Singleton' pattern
extends Node

# TODO: is there really a need for the active room thing?
var active_room: RoomController

signal level_started(entry_room)
signal room_changed(room_exited, room_entered, direction)
signal room_completed(room)

func set_active_room(room: RoomController):
	# disconnect old room signals
	if active_room != null:
		active_room.disconnect("room_completed", self, "_on_RoomController_room_complete")
	# connect to new room signals
	room.connect("room_completed", self, "_on_RoomController_room_complete")
	active_room = room

func _on_LevelController_generation_finished(entry_room: RoomController):
	set_active_room(entry_room)
	emit_signal("level_started", entry_room)
	emit_signal("room_changed", null, entry_room, Defs.Direction.UP)

func _on_LevelController_room_changed(room_exited: RoomController, room_entered: RoomController, direction: int):
	set_active_room(room_entered)
	emit_signal("room_changed", room_exited, room_entered, direction)

func _on_RoomController_room_complete(room: Node2D):
	emit_signal("room_completed", room)
