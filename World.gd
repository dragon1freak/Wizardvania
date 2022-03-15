extends Node2D

var room_list : Array = []

onready var viewport : Viewport = get_parent()
onready var viewport_container : ViewportContainer = viewport.get_parent()

func _ready():
	GameManager.connect("save_failed_to_load", self, "_loading_failed")
	if File.new().file_exists("user://savedata.save"):
		GameManager.load_save()
	else:
		GUIController.level_loaded()
#	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1280, 720), 1)

var rooms_ready : int = 0
func room_is_ready() -> void:
	if room_list.size() <= 0:
		get_tree().get_nodes_in_group("rooms")
	rooms_ready += 1
	if rooms_ready >= room_list.size():
		GUIController.level_loaded()

func _loading_failed() -> void:
	GUIController.level_loaded()
