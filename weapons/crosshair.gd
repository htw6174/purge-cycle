extends Sprite

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta):
	# follow mouse
	self.position = get_viewport().get_mouse_position()
