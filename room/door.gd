extends Node2D

class_name Door

export(bool) var is_active = true setget set_is_active
export(bool) var is_open = false setget set_is_open

signal entered()

func set_is_active(target_state: bool):
	self.visible = target_state
	# reverse order depending on current state, so that set_is_open always works
	if is_active:
		set_is_open(target_state)
		is_active = target_state
	else:
		is_active = target_state
		set_is_open(target_state)

func set_is_open(target_state: bool):
	if is_active:
		if is_open != target_state:
			if target_state == true:
				$AnimationPlayer.play("door_open")
			else:
				$AnimationPlayer.play("door_close")
				
		is_open = target_state
		$TriggerArea/Trigger.set_deferred("disabled", not target_state)
		$ClosedBody/Collider.set_deferred("disabled", target_state)

func open():
	set_is_open(true)

func close():
	set_is_open(false)


func _on_TriggerArea_body_entered(body):
	if is_open and is_active and body.is_in_group("Player"):
		emit_signal("entered")
