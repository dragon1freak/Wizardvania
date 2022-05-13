extends StaticBody2D
class_name SlamBlocker

var open : bool = false

func handle_break() -> void:
	$Sprite.visible = false
	$LightOccluder2D.visible = false
	$BreakAnimation.visible = true
	$BreakAnimation.frame = 0
	$BreakAnimation.play("default")
	$BreakSound.play()
	$CollisionShape2D.set_deferred("disabled", true)

func reset() -> void:
	self.open = false
	self.visible = true
	$CollisionShape2D.set_deferred("disabled", false)

func load_state(is_open : bool) -> void:
	self.open = is_open
	self.visible = !is_open
	$CollisionShape2D.set_deferred("disabled", is_open)

func save_state() -> bool:
	return self.open

func _on_BreakAnimation_animation_finished():
	self.open = true
	self.visible = false

