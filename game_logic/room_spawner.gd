extends Node2D

export(PackedScene) var room_scene: PackedScene
export(int) var room_count: int = 4
export(float) var room_height: float = 100 # TODO: any way to automatically determine this?

var rooms: Array

func _ready():
	spawn_rooms()

func spawn_rooms():
	rooms.resize(room_count)
	for i in room_count:
		var new_room: RoomController = room_scene.instance()
		self.add_child(new_room)
		new_room.owner = self
		if i > 0:
			rooms[i - 1].next_room = new_room
		new_room.position = Vector2(0, -room_height * i)
		rooms[i] = new_room
	rooms[-1].next_room = rooms[0]
