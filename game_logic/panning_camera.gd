extends Camera2D

func _ready():
	GameController.connect("room_changed", self, "_on_GameController_room_changed")

func _on_GameController_room_changed(room_exited: Node2D, room_entered: Node2D, direction: int):
	var tween = self.create_tween()
	tween.tween_property(self, "offset", room_entered.position, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()
