extends Control

class_name Prompt

const chars_per_second: float = 50.0

# Note on best practices: using nodepath exports to connect to child scenes seems to be the best approach, as the reference will be correctly updated when the scenetree changes. However, when used on scripts attached to the root of a reused scene, this has the issue of exposing those nodepaths wherever the scene is instanced. Is there currently or in 4.0 the ability to hide some exports from instanced scenes i.e. public/private fields?
export(NodePath) var prompt_label_path: NodePath
onready var prompt_label: RichTextLabel = get_node(prompt_label_path)
export(NodePath) var yes_button_path: NodePath
onready var yes_button: Button = get_node(yes_button_path)
export(NodePath) var no_button_path: NodePath
onready var no_button: Button = get_node(no_button_path)

signal yes_chosen()
signal no_chosen()
signal response_received(was_yes_chosen) # bool

func _ready():
	GameController.connect("player_prompted", self, "_on_GameController_player_prompted")
	self.connect("response_received", GameController, "_on_Prompt_response_received")
	self.visible = false

func present(prompt_text: String, yes_text: String, no_text: String):
	get_tree().paused = true
	self.visible = true
	prompt_label.text = prompt_text
	yes_button.text = yes_text
	no_button.text = no_text
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var text_tween = self.create_tween()
	var char_count = prompt_text.length()
	var duration = char_count / chars_per_second
	prompt_label.visible_characters = 0
	yes_button.disabled = true
	no_button.disabled = true
	text_tween.tween_property(prompt_label, "visible_characters", char_count, duration)
	text_tween.tween_callback(yes_button, "set_disabled", [false])
	text_tween.tween_callback(no_button, "set_disabled", [false])

func close():
	get_tree().paused = false
	self.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_GameController_player_prompted(prompt_text: String, yes_text: String, no_text: String):
	present(prompt_text, yes_text, no_text)

func _on_YesButton_pressed():
	close()
	emit_signal("yes_chosen")
	emit_signal("response_received", true)


func _on_NoButton_pressed():
	close()
	emit_signal("no_chosen")
	emit_signal("response_received", false)
