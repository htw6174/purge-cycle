extends Node2D

func _process(delta):
	# follow mouse
	self.position = get_viewport().get_mouse_position()
