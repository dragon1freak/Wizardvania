extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fade_out(anim_speed : float = 1.0) -> void:
	$AnimationPlayer.playback_speed = anim_speed / Engine.time_scale
	$AnimationPlayer.play("FadeOut")

func fade_in(anim_speed : float = 1.0) -> void:
	$AnimationPlayer.playback_speed = anim_speed / Engine.time_scale
	$AnimationPlayer.play("FadeIn")
