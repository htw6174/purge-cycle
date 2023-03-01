extends KinematicBody2D

export(int) var hazard_rating: int = 1
export(int) var hp_max: int = 1
export(float) var move_speed: float = 20

var hp_current: int

var target: Node2D

func _ready():
	hp_current = hp_max

func _physics_process(delta):
	if target == null:
		var player_nodes = get_tree().get_nodes_in_group("Player")
		if player_nodes.size() > 0:
			target = player_nodes[0]
	if target:
		var to_vector = self.global_position.direction_to(target.global_position)
		self.move_and_slide(to_vector * move_speed)

func take_damage(amount: int):
	hp_current -= amount
	if hp_current <= 0:
		self.queue_free()


func _on_HitBoxArea_area_entered(area):
	take_damage(1)
