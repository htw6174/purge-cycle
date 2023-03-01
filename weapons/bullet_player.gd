extends Node2D

class_name Bullet

var speed: float = 100
var velocity: Vector2

func fire_towards(target: Node2D):
	var dir = self.global_position.direction_to(target.global_position)
	velocity = dir * speed
	self.rotation = dir.angle()

func _physics_process(delta):
	self.position += velocity * delta

func self_destruct():
	self.queue_free()


func _on_Timer_timeout():
	self_destruct()


func _on_PlayerBullet_body_entered(body):
	self_destruct()
