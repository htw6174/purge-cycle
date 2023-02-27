extends Node

class_name LevelController

const room_inner_size: Vector2 = Vector2(160, 90)
const room_padding: Vector2 = Vector2(20, 20)
const room_size: Vector2 = room_inner_size + room_padding

signal generation_finished()
signal room_changed(room_exited, room_entered, direction)

export(int) var max_width: int = 5
export(int) var max_height: int = 5
export(PackedScene) var room_scene: PackedScene

var rooms: Array# Array of Array of RoomController

func _ready():
	self.connect("generation_finished", GameController, "_on_LevelController_generation_finished")
	self.connect("room_changed", GameController, "_on_LevelController_room_changed")
	# hacky way to ensure rest of scene is loaded before generation starts
	get_tree().root.connect("ready", self, "_on_Root_ready")

func _on_Root_ready():
	generate_level()

func generate_level():
	randomize()
	
	rooms = []
	rooms.resize(max_height)
	for i in rooms.size():
		var room_row = []
		room_row.resize(max_width)
		rooms[i] = room_row
	
	# place start room on the middle left
	var mid_row: int = max_height / 2
	var next_room_position: Vector2 = Vector2(0, mid_row)
	# store for signal after generation is complete
	var entry_room = create_room(next_room_position.x, next_room_position.y)
	# TODO: add level exit to RoomController, enable on entry_room
	# place next room to the right
	var next_room_direction = Defs.Direction.RIGHT
	next_room_position += Defs.direction_vectors[next_room_direction]
	var next_room_inside: bool = is_position_inside_level(next_room_position)
	# keep adding rooms to the right, top, or bottom until right edge is hit
	while next_room_inside:
		create_room(next_room_position.x, next_room_position.y)
		# determine valid directions for new room
		# only pick from first 3 directions i.e. don't go left
		var valid = [Defs.Direction.UP, Defs.Direction.DOWN, Defs.Direction.RIGHT]
		if next_room_position.y == 0 or next_room_direction == Defs.Direction.DOWN:
			# at top of level, or current room is below previous => can't go up
			valid.erase(Defs.Direction.UP)
		if next_room_position.y == max_height - 1 or next_room_direction == Defs.Direction.UP:
			# at bottom of level, or current room is above previous => can't go down
			valid.erase(Defs.Direction.DOWN)
		# pick from remaining options
		next_room_direction = valid[randi() % valid.size()]
		next_room_position += Defs.direction_vectors[next_room_direction]
		next_room_inside = is_position_inside_level(next_room_position)
	# TODO: add purge cycle switch to last room
	# TODO: add side rooms
	# Go back through all rooms to do post-generation setup (enable connecting doors etc.)
	for y in rooms.size():
		for x in rooms[y].size():
			var room = rooms[y][x] as RoomController
			if room != null:
				# check up and right for rooms, set doors on both active
				var up: RoomController
				if y + 1 >= rooms.size():
					up = null
				else:
					up = rooms[y + 1][x]
				if up != null:
					room.activate_door(Defs.Direction.DOWN)
					up.activate_door(Defs.Direction.UP)
				
				var right: RoomController
				if x + 1 >= rooms[y].size():
					right = null
				else:
					right = rooms[y][x + 1]
				if right != null:
					room.activate_door(Defs.Direction.RIGHT)
					right.activate_door(Defs.Direction.LEFT)
	emit_signal("generation_finished", entry_room)

func create_room(x: int, y: int):
	var new_room = room_scene.instance() as RoomController
	self.add_child(new_room)
	new_room.owner = self
	new_room.position = Vector2(x, y) * room_size
	new_room.level_position = Vector2(x, y)
	new_room.connect("door_entered", self, "_on_RoomController_door_entered")
	rooms[y][x] = new_room
	return new_room

func is_position_inside_level(room_position: Vector2) -> bool:
	if room_position.x < 0 or room_position.y < 0 or room_position.x >= max_width or room_position.y >= max_height:
		return false
	else:
		return true

func _on_RoomController_door_entered(room: RoomController, direction: int):
	var dest_position = room.level_position + Defs.direction_vectors[direction]
	if is_position_inside_level(dest_position):
		var dest_room = rooms[dest_position.y][dest_position.x]
		if dest_room != null:
			emit_signal("room_changed", room, dest_room, direction)
		else:
			print_debug("ERROR: door points to non-existant room")
	else:
		print_debug("ERROR: door points outside level bounds")
