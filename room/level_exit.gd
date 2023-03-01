extends Node

export(bool) var is_open: bool = false
export(NodePath) var closed_collider_path: NodePath
onready var closed_collider: CollisionShape2D = get_node(closed_collider_path)

signal entered()

func _ready():
	GameController.connect("purge_activated", self, "_on_GameController_purge_activated")
	closed_collider.set_deferred("disabled", is_open)

func _on_GameController_purge_activated():
	is_open = true
	closed_collider.set_deferred("disabled", true)
	$Polygon2D.color = Color.white


func _on_TriggerArea_body_entered(body):
	if is_open and body.is_in_group("Player"):
		emit_signal("entered")
