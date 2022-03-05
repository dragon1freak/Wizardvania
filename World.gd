extends Node2D

var room_list : Array = []

func _ready():
	if File.new().file_exists("user://savedata.save"):
		GameManager.load_save()
	else:
		GUIController.level_loaded()
	GameManager.connect("save_failed_to_load", self, "_loading_failed")


var rooms_ready : int = 0
func room_is_ready() -> void:
	if room_list.size() <= 0:
		get_tree().get_nodes_in_group("rooms")
	rooms_ready += 1
	print(rooms_ready)
	if rooms_ready >= room_list.size():
		GUIController.level_loaded()

func _loading_failed() -> void:
	GUIController.level_loaded()
