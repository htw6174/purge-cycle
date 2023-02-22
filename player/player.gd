extends KinematicBody2D

export(float) var move_speed: float = 60
export(PackedScene) var bullet_scene: PackedScene

var fire_tween

func _ready():
	fire_tween = self.create_tween().set_loops()
	fire_tween.tween_callback(self, "fire").set_delay(1) # TODO: use default weapon delay
	fire_tween.stop()

func _process(delta):
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
	new_shot.position = self.position
