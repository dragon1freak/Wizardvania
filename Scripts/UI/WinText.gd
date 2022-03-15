extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_menu() -> void:
	visible = true
	GUIController.pause_container.visible = true
	if GUIController.player != null:
		GUIController.player.toggle_pause(true)
	yield(get_tree().create_timer(1),"timeout")
	$CenterContainer/Continue.grab_focus()

func _on_Continue_pressed():
	GameManager.quit_to_menu()
