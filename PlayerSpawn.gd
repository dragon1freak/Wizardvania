extends Sprite

var is_active : bool = false

func activate() -> void:
	$AnimationPlayer.play("Activate")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("Active")
