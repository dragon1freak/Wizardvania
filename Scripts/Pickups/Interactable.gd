extends Node
class_name Interactable

var can_interact : bool = false

func _unhandled_input(event):
	if event.is_action_pressed("action") && can_interact:
		self.interact()

func interact() -> void:
	pass
