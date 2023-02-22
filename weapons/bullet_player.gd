extends Node

func self_destruct():
	self.queue_free()


func _on_Timer_timeout():
	self_destruct()
