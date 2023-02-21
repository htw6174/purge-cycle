extends Node2D

class_name RoomController

var next_room: RoomController

signal room_complete(room)
signal room_exited(room)

func _ready():
	self.connect("room_exited", GameController, "_on_RoomController_room_exited")

func _on_ExitArea_body_entered(body: Node):
	if body.is_in_group("Player"):
		emit_signal("room_exited", self)
