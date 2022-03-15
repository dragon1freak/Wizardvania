extends Node2D

var current_input : String = "keyboard"
# Called when the node enters the scene tree for the first time.
func _ready():
	InputHelper.connect("device_changed", self, "_on_input_device_changed")
	current_input = InputHelper.guess_device_name()
	if InputHelper.guess_device_name() == "keyboard":
		$KeyboardSprite.visible = true
		$ConsoleSprite.visible = false
	else:
		$KeyboardSprite.visible = false
		$ConsoleSprite.visible = true

func _on_input_device_changed(device : String, device_index : int) -> void:
	if device == "keyboard":
		$KeyboardSprite.visible = true
		$ConsoleSprite.visible = false
	else:
		$KeyboardSprite.visible = false
		$ConsoleSprite.visible = true
