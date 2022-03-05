extends Area2D

func _on_Dangers_body_entered(body):
	if body is Player:
		body.handle_death()
