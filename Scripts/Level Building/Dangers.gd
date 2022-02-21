extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Dangers_body_entered(body):
	if body is Player:
		body.handle_death()


func _on_Dangers_body_exited(body):
	pass # Replace with function body.
