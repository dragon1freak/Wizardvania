extends Interactable

onready var indicator_sprite : Sprite = $Indicator
var player : Player = null

func _on_LeftGem_body_entered(body):
	if body is Player:
		if !player:
			player = body
		can_interact = true
		indicator_sprite.visible = true

func _on_LeftGem_body_exited(body):
	if body is Player:
		can_interact = false
		indicator_sprite.visible = false

func interact() -> void:
	PlayerManager.set_state("HAS_LEFT_GEM")
	player.set_state()
	self.queue_free()

func check_state() -> void:
	if PlayerManager.HAS_LEFT_GEM:
		self.queue_free()
