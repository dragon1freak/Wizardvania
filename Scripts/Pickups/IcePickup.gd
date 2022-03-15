extends Interactable

onready var indicator_sprite : Node2D = $Indicator
var player : Player = null

func _on_IcePickup_body_entered(body):
	if body is Player:
		if !player:
			player = body
		can_interact = true
		indicator_sprite.visible = true

func _on_IcePickup_body_exited(body):
	if body is Player:
		can_interact = false
		indicator_sprite.visible = false

func interact() -> void:
	PlayerManager.set_state("HAS_ICE")
	GUIController.ice_text.show_menu()
	player.set_state()
	self.queue_free()

func check_state() -> void:
	if PlayerManager.HAS_ICE:
		self.queue_free()
