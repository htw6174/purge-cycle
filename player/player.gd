extends KinematicBody2D

export(float) var speed: float = 60

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
		move_vector = move_vector.normalized() * speed * delta
		
	self.move_and_collide(move_vector)
