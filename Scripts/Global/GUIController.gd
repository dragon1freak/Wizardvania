extends CanvasLayer

onready var rooms : Array = get_tree().get_nodes_in_group("rooms")
var player : Player = null
var in_game : bool = false

onready var pause_container : MarginContainer = $MiniMap/PauseContainer
onready var map_segments : Control = $MiniMap/PauseContainer/CenterContainer/MapBufferContainer/MapSegments
onready var pause_menu : Control = $MiniMap/PauseContainer/PauseMenu
onready var pause_options : Control = $MiniMap/PauseContainer/PauseOptions
onready var quit_confirm : Control = $MiniMap/PauseContainer/QuitConfirm

onready var alt_move_text : Control = $MiniMap/PauseContainer/AltMoveText
onready var alt_jump_text : Control = $MiniMap/PauseContainer/AltJumpText
onready var fire_text : Control = $MiniMap/PauseContainer/FireText
onready var ice_text : Control = $MiniMap/PauseContainer/IceText
onready var win_text : Control = $MiniMap/PauseContainer/WinText

var main_volume : float = 0.8
var music_volume : float = 0.8
var sfx_volume : float = 0.8
var is_fullscreen : bool = false

func fade_out(anim_speed : float = 1.0) -> void:
	$AnimationPlayer.playback_speed = anim_speed / Engine.time_scale
	$AnimationPlayer.play("FadeOut")

func fade_in(anim_speed : float = 1.0) -> void:
	$AnimationPlayer.playback_speed = anim_speed / Engine.time_scale
	$AnimationPlayer.play("FadeIn")

func level_loaded() -> void:
	AudioManager.start_game()
	fade_in()
	in_game = true
	pause_options.get_node("VBoxContainer/FullscreenCheck/CheckBox").pressed = OS.window_fullscreen
	pause_options.get_node("VBoxContainer/ElementStateCheck/CheckBox").pressed = PlayerManager.TOGGLE_STATES
	pause_options.get_node("VBoxContainer/MainVolumeSlider/HSlider").value = self.main_volume
	pause_options.get_node("VBoxContainer/MusicVolumeSlider/HSlider").value = self.music_volume
	pause_options.get_node("VBoxContainer/SoundsVolumeSlider/HSlider").value = self.sfx_volume
	yield($AnimationPlayer, "animation_finished")
	$Fade/LoadingSprite.visible = false

func toggle_fullscreen(value : bool = false):
	OS.window_fullscreen = value
	GUIController.is_fullscreen = OS.window_fullscreen

func _unhandled_input(event):
	if in_game:
		if event.is_action_pressed("toggle_map") && !pause_options.visible && !quit_confirm.visible:
			toggle_map_screen()
		elif event.is_action_pressed("pause"):
			toggle_pause_menu()

func toggle_pause_menu() -> void:
	pause_menu.visible = !pause_menu.visible
	pause_options.visible = false
	quit_confirm.visible = false
	if pause_menu.visible:
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1280, 720), 1)
		pause_menu.get_node("VBoxContainer/Resume").grab_focus()
#	else:
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1280, 720), 1)
	map_segments.visible = false
	pause_container.visible = pause_menu.visible
	if player != null:
		player.toggle_pause(pause_container.visible)

func toggle_map_screen() -> void:
	map_segments.visible = !map_segments.visible
	pause_menu.visible = false
	pause_container.visible = map_segments.visible
	if player != null:
		player.toggle_pause(pause_container.visible)

func toggle_pause_options() -> void:
	pause_options.visible = !pause_options.visible
	map_segments.visible = false
	pause_menu.visible = false
	if pause_options.visible:
		pause_options.get_node("VBoxContainer/MainVolumeSlider/HSlider").grab_focus()
	if player != null:
		player.toggle_pause(pause_container.visible)

func toggle_quit_confirm() -> void:
	quit_confirm.visible = !quit_confirm.visible
	pause_menu.visible = false
	if quit_confirm.visible:
		quit_confirm.get_node("VBoxContainer/QuitAbort").grab_focus()

func _on_Resume_pressed():
	toggle_pause_menu()

func _on_Pause_Options_pressed():
	toggle_pause_options()

func _on_Pause_Quit_pressed():
	toggle_quit_confirm()

func _on_MainVolumeSlider_slider_value_changed(value : float):
	self.main_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))
	print(value)

func _on_MusicVolumeSlider_slider_value_changed(value):
	self.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))
	print(value)

func _on_SoundsVolumeSlider_slider_value_changed(value):
	self.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear2db(value))
	print(value)

func _on_PauseOptionsBack_pressed():
	toggle_pause_menu()
	GameManager.save_settings()

func _on_FullscreenCheck_check_value_changed(value : bool):
	toggle_fullscreen(value)

func _on_ElementStateCheck_check_value_changed(value : bool):
	PlayerManager.set_toggle_states(value)

func _on_QuitConfirm_pressed():
	GameManager.quit_to_menu()

func _on_QuitAbort_pressed():
	toggle_pause_menu()

func _on_Continue_pressed():
	pass # Replace with function body.
