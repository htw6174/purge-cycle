extends Node

var active_room: RoomController

signal room_exited(current_room, next_room)
signal room_completed(room)

func set_active_room(room: RoomController):
	# disconnect old room signals
	active_room.disconnect("room_exited", self, "_on_RoomController_room_exited")
	# connect to new room signals
	room.connect("room_exited", self, "_on_RoomController_room_exited")
	active_room = room
	

func _on_RoomController_room_exited(room: RoomController):
	emit_signal("room_exited", room, room.next_room)

func _on_RoomController_room_complete(room: Node2D):
	emit_signal("room_completed", room) # TODO: figure out how to set up room layout
