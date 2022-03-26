extends CanvasLayer

onready var mm_container : VBoxContainer = $MenuContainer/MainMenuContainer
onready var options_container : VBoxContainer = $MenuContainer/OptionsContainer
onready var ngc_container : VBoxContainer = $MenuContainer/NewGameConfirm
onready var controls_container : VBoxContainer = $MenuContainer/Controls

func _ready() -> void:
	if File.new().file_exists("user://savedata.save"):
		mm_container.get_node("ContinueButton").disabled = false
		mm_container.get_node("ContinueButton").focus_mode = 2
		mm_container.get_node("ContinueButton").grab_focus()
	else:
		mm_container.get_node("ContinueButton").disabled = true
		mm_container.get_node("ContinueButton").focus_mode = 0
		mm_container.get_node("NewGameButton").grab_focus()
	AudioManager.game_loaded()
	GUIController.in_game = false

func _on_ContinueButton_pressed():
	GameManager.continue_game()

func _on_NewGameButton_pressed():
	if File.new().file_exists("user://savedata.save"):
		toggle_new_game_confirm()
	else:
		GameManager.start_new_game()

func _on_OptionsButton_pressed():
	toggle_options()

func _on_QuitButton_pressed():
	GameManager.quit_game()

func _on_OptionsBack_pressed():
	toggle_options()
	GameManager.save_settings()

func toggle_options() -> void:
	options_container.visible = !options_container.visible
	mm_container.visible = !mm_container.visible
	if options_container.visible:
		set_values()
		options_container.get_node("MainVolumeSlider/HSlider").grab_focus()
	elif mm_container.visible:
		mm_container.get_node("NewGameButton").grab_focus()

func toggle_controls_menu() -> void:
	controls_container.visible = !controls_container.visible
	mm_container.visible = !mm_container.visible
	if controls_container.visible:
		controls_container.get_node("ControlsBack").grab_focus()
	elif mm_container.visible:
		mm_container.get_node("NewGameButton").grab_focus()

func toggle_new_game_confirm() -> void:
	ngc_container.visible = !ngc_container.visible
	mm_container.visible = !mm_container.visible
	if ngc_container.visible:
		ngc_container.get_node("NewGameAbort").grab_focus()
	elif mm_container.visible:
		mm_container.get_node("NewGameButton").grab_focus()

func _on_MainVolumeSlider_slider_value_changed(value : float):
	GUIController.main_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))
	print(value)

func _on_MusicVolumeSlider_slider_value_changed(value):
	GUIController.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))
	print(value)

func _on_SoundsVolumeSlider_slider_value_changed(value):
	GUIController.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear2db(value))
	print(value)

func _on_FullscreenCheck_check_value_changed(value):
	GUIController.toggle_fullscreen(value)

func _on_ElementStateCheck_check_value_changed(value):
	PlayerManager.set_toggle_states(value)

func set_values() -> void:
	options_container.get_node("FullscreenCheck/CheckBox").pressed = OS.window_fullscreen
	options_container.get_node("ElementStateCheck/CheckBox").pressed = PlayerManager.TOGGLE_STATES
	options_container.get_node("MainVolumeSlider/HSlider").value = GUIController.main_volume
	options_container.get_node("MusicVolumeSlider/HSlider").value = GUIController.music_volume
	options_container.get_node("SoundsVolumeSlider/HSlider").value = GUIController.sfx_volume

func _on_NewGameConfirm_pressed():
	GameManager.start_new_game()

func _on_NewGameAbort_pressed():
	toggle_new_game_confirm()


func _on_ControlsButton_pressed():
	toggle_controls_menu()

func _on_ControlsBack_pressed():
	toggle_controls_menu()
