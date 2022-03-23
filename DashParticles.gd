extends AnimatedSprite

func _ready():
	self.frame = 0
	self.playing = true

func _on_AnimatedSprite_animation_finished():
	self.queue_free()
