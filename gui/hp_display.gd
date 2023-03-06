extends Control

export(PackedScene) var heart_scene: PackedScene

func _ready():
	GameController.connect("hp_changed", self, "_on_Player_hp_changed")

func update_display(new_hp: int):
	var hearts = self.get_children()
	var current_displayed_hp = hearts.size()
	if current_displayed_hp > new_hp and current_displayed_hp > 0:
		# destroy hearts
		var count_to_destroy = min(current_displayed_hp, current_displayed_hp - new_hp)
		for i in count_to_destroy:
			hearts[-i].queue_free()
	elif current_displayed_hp < new_hp:
		# create new hearts
		var count_to_create = new_hp - current_displayed_hp
		for i in count_to_create:
			var new_heart = heart_scene.instance()
			self.add_child(new_heart)
	else:
		# no change
		pass

func _on_Player_hp_changed(new_hp: int):
	update_display(new_hp)
