extends Control

signal settings_loaded
signal save_loaded
signal save_failed_to_load
signal set_save_data(room_id, save_data)

# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings()

func start_new_game() -> void:
	GUIController.fade_out()
	var dir : Directory = Directory.new()
	dir.remove("user://savedata.save")
	yield(GUIController.get_node("AnimationPlayer"), "animation_finished")
	get_tree().change_scene("res://Scenes/Levels/World.tscn")

func continue_game() -> void:
	GUIController.fade_out()
	yield(GUIController.get_node("AnimationPlayer"), "animation_finished")
	get_tree().change_scene("res://Scenes/Levels/World.tscn")

func quit_game() -> void:
	save_game()
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func quit_to_menu() -> void:
	GUIController.fade_out()
	save_game()
	AudioManager.current_room = null
	GUIController.player = null
	yield(GUIController.get_node("AnimationPlayer"), "animation_finished")
	GUIController.toggle_pause_menu()
	GUIController.toggle_pause_menu()
	get_tree().change_scene("res://Scenes/Levels/MainMenu.tscn")
	GUIController.fade_in()

func save_game() -> void:
	var rooms : Array = get_tree().get_nodes_in_group("rooms")
	if rooms.size() > 0:
		var save_data : Dictionary = {"rooms": []}
		for room in rooms:
			var room_data = room.get_save_state()
			save_data["rooms"].push_front(room_data)
		save_data["player_state"] = PlayerManager.get_save_state()
		var save_file : File = File.new()
		var _res = save_file.open("user://savedata.save", File.WRITE)
		save_file.store_line(to_json(save_data))
		save_file.close()

func load_save() -> void:
	var rooms : Array = get_tree().get_nodes_in_group("rooms")
	var save_file : File = File.new()
	if save_file.file_exists("user://savedata.save"):
		var _res = save_file.open("user://savedata.save", File.READ)
		var save_data = parse_json(save_file.get_line())
		save_file.close()
		for room in save_data["rooms"]:
			emit_signal("set_save_data", room["room_id"], room)
		PlayerManager.set_save_state(save_data["player_state"])
		emit_signal("save_loaded")
	else:
		emit_signal("save_failed_to_load")

func save_settings() -> void:
	var save_data : Dictionary = {"main_vol": GUIController.main_volume, "music_vol": GUIController.music_volume,
									"sounds_vol": GUIController.sfx_volume, "is_fullscreen": OS.window_fullscreen, 
									"toggle_state": PlayerManager.TOGGLE_STATES}
	var save_file : File = File.new()
	var _res = save_file.open("user://settings.save", File.WRITE)
	save_file.store_line(to_json(save_data))
	save_file.close()

func load_settings() -> void:
	var save_file : File = File.new()
	if save_file.file_exists("user://settings.save"):
		var _res = save_file.open("user://settings.save", File.READ)
		var save_data = parse_json(save_file.get_line())
		GUIController.main_volume = save_data["main_vol"]
		GUIController.music_volume = save_data["music_vol"]
		GUIController.sfx_volume = save_data["sounds_vol"]
		GUIController.is_fullscreen = save_data["is_fullscreen"]
		PlayerManager.TOGGLE_STATES = save_data["toggle_state"]
		save_file.close()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(GUIController.main_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear2db(GUIController.sfx_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(GUIController.music_volume))
	GUIController.toggle_fullscreen(GUIController.is_fullscreen)
	emit_signal("settings_loaded")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit()
