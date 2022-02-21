extends StaticBody2D
class_name SlamBlocker

var open : bool = false

func handle_break() -> void:
	open = true
	self.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
