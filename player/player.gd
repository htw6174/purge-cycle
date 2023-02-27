extends KinematicBody2D

class_name Player

export(float) var move_speed: float = 60
export(PackedScene) var bullet_scene: PackedScene

var controls_enabled = true
var fire_tween

func _ready():
	GameController.connect("level_started", self, "_on_GameController_level_started")
	GameController.connect("room_changed", self, "_on_GameController_room_changed")
	
	fire_tween = self.create_tween().set_loops()
	fire_tween.tween_callback(self, "fire").set_delay(0.2) # TODO: use default weapon delay
	fire_tween.stop()

func _process(delta):
	if controls_enabled:
		var move_vector = Vector2.ZERO
		if Input.is_action_pressed("move_right"):
			move_vector.x += 1
		if Input.is_action_pressed("move_left"):
			move_vector.x -= 1
		if Input.is_action_pressed("move_down"):
			move_vector.y += 1
		if Input.is_action_pressed("move_up"):
			move_vector.y -= 1
		
		if move_vector.length() > 0:
			move_vector = move_vector.normalized() * move_speed * delta
			
		self.move_and_collide(move_vector)
		
		if Input.is_action_just_pressed("fire_primary"):
			start_fire()
		elif Input.is_action_just_released("fire_primary"):
			stop_fire()

func start_fire():
	fire()
	fire_tween.play()

func stop_fire():
	fire_tween.stop()

func fire():
	print("Fire!")
	var new_shot = bullet_scene.instance()
	new_shot.position = self.position + $BulletOrigin.position
	$Unattached/FiredShots.add_child(new_shot)
	#new_shot.owner = $Unattached/FiredShots

func start_room_change(room_entered: RoomController, direction: int):
	# disable collider, move to next room, re-enable collider
	$CollisionShape2D.set_deferred("disabled", true)
	self.controls_enabled = false
	
	var move_tween = self.create_tween()
	move_tween.tween_property(self, "position", room_entered.get_entry_point(direction), 0.5)
	move_tween.tween_callback(self, "end_room_change")
	move_tween.play()

func end_room_change():
	$CollisionShape2D.set_deferred("disabled", false)
	self.controls_enabled = true

func _on_GameController_level_started(entry_room: RoomController):
	self.position = entry_room.position

func _on_GameController_room_changed(room_exited, room_entered, direction):
	start_room_change(room_entered, direction)
