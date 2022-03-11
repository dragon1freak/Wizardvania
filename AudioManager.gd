extends Node

onready var music1 : AudioStream = preload("res://TitleThemeWV.ogg")
onready var music2 : AudioStream = preload("res://MainThemeWV.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_sound_bus("Sounds")
	SoundManager.set_default_ui_sound_bus("Sounds")
	pass # Replace with function body.

func game_loaded() -> void:
	SoundManager.play_music(music1, 1)
