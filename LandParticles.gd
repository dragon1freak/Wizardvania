extends AnimatedSprite

onready var anims : Array = self.frames.get_animation_names()

func _ready():
	self.frame = 0
	self.play(anims[randi() % anims.size()])

func _on_LandParticles_animation_finished():
	self.queue_free()
