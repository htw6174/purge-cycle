extends Node2D

class_name Door

export(bool) var is_open = false setget set_is_open

signal entered()

func set_is_open(target_state: bool):
	is_open = target_state
	$TriggerArea/Trigger.set_deferred("disabled", not target_state)
	$ClosedBody/Collider.set_deferred("disabled", target_state)

func open():
	set_is_open(true)
	$AnimationPlayer.play("door_open")

func close():
	set_is_open(false)
	$AnimationPlayer.play("door_close")


func _on_TriggerArea_body_entered(body):
	if is_open and body.is_in_group("Player"):
		emit_signal("entered")
