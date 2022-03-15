extends Node

onready var music1 : AudioStream = preload("res://TitleThemeWV.ogg")
onready var music2 : AudioStream = preload("res://MainThemeWV.ogg")

var last_track : AudioStream

var current_room : Node2D
var main_menu : bool = true
# Called when the node enters the scene tree for the first time.
func _ready():
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_sound_bus("Sounds")
	SoundManager.set_default_ui_sound_bus("Sounds")

func game_loaded() -> void:
	SoundManager.play_music(music1, 1)

func start_game() -> void:
	SoundManager.play_music(music1, 1)
	var loop_timer : SceneTreeTimer = get_tree().create_timer(get_loop_time(music1))
	loop_timer.connect("timeout", self, "_on_music_loop_finished")

func get_loop_time(track : AudioStream, loops : float = 2.0, fade_out_time : float = 4.0) -> float:
	return (track.get_length() * loops) - fade_out_time

func _on_music_loop_finished() -> void:
	if !main_menu && !current_room.is_challenge_room:
		SoundManager.stop_music(4)
		var start_timer : SceneTreeTimer = get_tree().create_timer(ceil(rand_range(30, 60)))
		start_timer.connect("timeout", self, "_on_music_loop_start")
		print("looped")
	elif !main_menu:
		var loop_timer : SceneTreeTimer = get_tree().create_timer(get_loop_time(music2))
		loop_timer.connect("timeout", self, "_on_music_loop_finished")

func _on_music_loop_start() -> void:
	SoundManager.play_music(music2, 4)
	var loop_timer : SceneTreeTimer = get_tree().create_timer(get_loop_time(music1))
	loop_timer.connect("timeout", self, "_on_music_loop_finished")

func set_current_room(new_room : Node2D) -> void:
	if new_room.is_challenge_room:
		SoundManager.play_music(music2, 1)
	elif !new_room.is_challenge_room && current_room != null && current_room.is_challenge_room:
		SoundManager.play_music(music1, 1)
	current_room = new_room
