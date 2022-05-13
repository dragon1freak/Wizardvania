extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_menu() -> void:
	get_parent().visible = true
	get_parent().get_node("CenterContainer").visible = false
	GUIController.get_node("AnimationPlayer").play("WinFade")
	GUIController.winning = true
	GUIController.in_game = false

func show_end_text() -> void:
	get_parent().color = Color(0,0,0)
	get_parent().get_node("CenterContainer").visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	yield(get_tree().create_timer(0.5),"timeout")
	get_parent().get_node("CenterContainer/Continue").grab_focus()

func _on_Continue_pressed():
	GameManager.quit_to_menu()
