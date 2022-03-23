extends AnimatedSprite

onready var anims : Array = self.frames.get_animation_names()

func _ready():
	self.frame = 0
	self.play(anims[randi() % anims.size()])

func _on_AnimatedSprite_animation_finished():
	self.stop()
	yield(get_tree().create_timer(1.5),"timeout")
	$AnimationPlayer.play("FadeAway")


func _on_AnimationPlayer_animation_finished(anim_name):
	self.queue_free()
