extends KinematicBody2D

class_name Enemy

export(Resource) var preset: Resource # EnemyPreset

export(NodePath) var hp_label_path: NodePath
onready var hp_label: Label = get_node(hp_label_path)

var hp_current: int

var target: Node2D

signal died()

func _ready():
	assert(preset != null and preset is EnemyPreset)
	hp_current = preset.hp_max
	hp_label.text = "{0}/{1}".format([hp_current, preset.hp_max])
	self.scale *= preset.size_scale
	$AnimationPlayer.play("spawn_drop")

func _physics_process(delta):
	if target == null:
		var player_nodes = get_tree().get_nodes_in_group("Player")
		if player_nodes.size() > 0:
			target = player_nodes[0]
	if target:
		var to_vector = self.global_position.direction_to(target.global_position)
		self.move_and_slide(to_vector * preset.move_speed)

func take_damage(amount: int):
	hp_current -= amount
	hp_label.text = "{0}/{1}".format([hp_current, preset.hp_max])
	if hp_current <= 0:
		emit_signal("died")
		self.queue_free()


func _on_HitBoxArea_area_entered(area):
	take_damage(1)
