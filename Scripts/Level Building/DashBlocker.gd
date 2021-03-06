extends StaticBody2D
class_name DashBlocker

var open : bool = false

func handle_break(direction : int = 1) -> void:
	$Sprite.visible = false
	$LightOccluder2D.visible = false
	$SmashAnimation.visible = true
	$SmashAnimation.frame = 0
	$SmashAnimation.play("right" if direction > 0 else "left")
	$BreakSound.play()

func reset() -> void:
	self.open = false
	self.visible = true
	self.set_collision_mask_bit(1, true)

func load_state(is_open : bool) -> void:
	self.open = is_open
	self.visible = !is_open
	self.set_collision_mask_bit(1, !is_open)

func save_state() -> bool:
	return self.open


func _on_SmashAnimation_animation_finished():
	self.open = true
	self.visible = false
#	$CollisionShape2D.set_deferred("disabled", true)
	self.set_collision_mask_bit(1, false)
