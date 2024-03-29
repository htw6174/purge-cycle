extends KinematicBody2D

class_name Player

export(float) var max_hp: int = 3
export(float) var move_speed: float = 120
export(PackedScene) var bullet_scene: PackedScene
export(NodePath) var crosshair_path: NodePath
onready var crosshair: Node2D = get_node(crosshair_path)
export(NodePath) var bullet_origin_path: NodePath
onready var bullet_origin: Node2D = get_node(bullet_origin_path)

var current_hp: int
var controls_enabled: bool = true
var fire_tween: SceneTreeTween

signal hp_changed(new_hp)
signal died()

func _ready():
	GameController.connect("level_started", self, "_on_GameController_level_started")
	GameController.connect("room_changed", self, "_on_GameController_room_changed")
	self.connect("hp_changed", GameController, "_on_Player_hp_changed")
	self.connect("died", GameController, "_on_Player_died")
	
	current_hp = max_hp
	emit_signal("hp_changed", current_hp)
	
	fire_tween = self.create_tween().set_loops()
	fire_tween.tween_callback(self, "fire").set_delay(0.2) # TODO: use default weapon delay
	fire_tween.stop()

func _physics_process(delta):
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
		
		if move_vector.x < 0:
			$Bottom.scale.x = -1
		else:
			$Bottom.scale.x = 1
		
		var aim_diff: Vector2 = get_global_mouse_position() - self.global_position
		if aim_diff.x < 0:
			$Top.scale.x = -1
		else:
			$Top.scale.x = 1
		
		if move_vector.length() > 0:
			move_vector = move_vector.normalized() * move_speed
		
		# velocity should NOT factor in delta
		self.move_and_slide(move_vector)
		
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
	var new_shot = bullet_scene.instance() as Bullet
	new_shot.position = bullet_origin.global_position
	$Unattached/FiredShots.add_child(new_shot)
	new_shot.fire_towards(crosshair)
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

func take_damage():
	current_hp -= 1
	emit_signal("hp_changed", current_hp)
	if current_hp <= 0:
		emit_signal("died")

func _on_GameController_level_started(entry_room: RoomController):
	self.position = entry_room.position

func _on_GameController_room_changed(room_exited, room_entered, direction):
	start_room_change(room_entered, direction)

func _on_HitBoxArea_area_entered(area):
	take_damage()
