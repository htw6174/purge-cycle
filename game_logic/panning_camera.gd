extends Camera2D

func _ready():
	GameController.connect("room_exited", self, "_on_GameController_room_exited")

func _on_GameController_room_exited(current_room: Node2D, next_room: Node2D):
	var tween = self.create_tween()
	tween.tween_property(self, "offset", next_room.position, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()
