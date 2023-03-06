# This is an autoload class
# The goal of this class is to allow for loose coupling by providing a central place for other nodes 
# to report 'game-wide' events to, and connect to signals representing other significant gameplay events,
# similar to GDQuest's 'Event Bus Singleton' pattern
extends Node

# TODO: is there really a need for the active room thing?
var active_room: RoomController
var is_purge_active: bool = false

signal level_started(entry_room)
signal level_exited()
signal level_changed()
signal room_changed(room_exited, room_entered, direction)
signal room_completed(room)
signal purge_activated(duration)
signal player_prompted(prompt_text, yes_text, no_text)
signal hp_changed(new_hp)

func set_active_room(room: RoomController):
	# disconnect old room signals
	if active_room != null:
		active_room.disconnect("room_completed", self, "_on_RoomController_room_completed")
	# connect to new room signals
	room.connect("room_completed", self, "_on_RoomController_room_completed")
	active_room = room

func _on_LevelController_generation_finished(entry_room: RoomController):
	set_active_room(entry_room)
	emit_signal("level_started", entry_room)
	emit_signal("room_changed", null, entry_room, Defs.Direction.UP)

func _on_LevelController_room_changed(room_exited: RoomController, room_entered: RoomController, direction: int):
	set_active_room(room_entered)
	emit_signal("room_changed", room_exited, room_entered, direction)

func _on_RoomController_room_completed(room: Node2D):
	emit_signal("room_completed", room)

func _on_PurgeSwitch_player_approached():
	# TODO: figure out a better way to store dialogue strings
	emit_signal("player_prompted", "It's a control console. \nFrom here, you can activate the Purge Cycle for this floor.", "Input activation sequence", "Not yet")

func _on_Prompt_response_received(was_yes_chosen: bool):
	if was_yes_chosen:
		is_purge_active = true
		emit_signal("purge_activated", 15.0)

func _on_LevelController_level_exited():
	is_purge_active = false
	emit_signal("level_exited")
	emit_signal("level_changed")

func _on_Player_hp_changed(new_hp: int):
	emit_signal("hp_changed", new_hp)

func _on_Player_died():
	print("gg loser")
	pass # TODO: pause + end game, show score screen
