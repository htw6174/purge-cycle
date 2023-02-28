extends Node

signal player_approached()

func _ready():
	self.connect("player_approached", GameController, "_on_PurgeSwitch_player_approached")

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("player_approached")
