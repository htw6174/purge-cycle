extends Node

signal timeout()

func _ready():
	GameController.connect("purge_activated", self, "_on_GameController_purge_activated")
	GameController.connect("level_exited", self, "_on_GameController_level_exited")
	self.connect("timeout", GameController, "_on_PurgeTimer_timeout")
	
	$Label.visible = false

func _process(delta):
	$Label.text = String($Timer.time_left).pad_decimals(2)

func _on_GameController_purge_activated(duration: float):
	$Label.visible = true
	$Timer.wait_time = duration
	$Timer.start()

func _on_GameController_level_exited():
	$Label.visible = false
	$Timer.stop()

func _on_Timer_timeout():
	emit_signal("timeout")
