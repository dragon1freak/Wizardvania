extends Interactable

onready var indicator_sprite : Node2D = $Indicator
var player : Player = null
var is_active : bool = false

func _on_FinalPorter_body_entered(body):
	if body is Player:
		if !player:
			player = body
		if is_active:
			can_interact = true
			indicator_sprite.visible = true

func _on_FinalPorter_body_exited(body):
	if body is Player:
		can_interact = false
		indicator_sprite.visible = false

func can_win() -> bool:
	return PlayerManager.HAS_ALT_JUMP && PlayerManager.HAS_ALT_MOVE && PlayerManager.HAS_FIRE && PlayerManager.HAS_ICE && PlayerManager.HAS_LEFT_GEM && PlayerManager.HAS_RIGHT_GEM

func interact() -> void:
	GUIController.win_text.show_menu()

func check_state() -> void:
	if can_win():
		is_active = true
		$Sprite.frame = 1
	else:
		is_active = false
		$Sprite.frame = 0
