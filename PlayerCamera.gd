extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player : Player = get_tree().get_nodes_in_group("player")[0]
onready var world = get_tree().get_nodes_in_group("world")[0]

var game_size := Vector2(384, 216)
onready var window_scale : float = (OS.window_size / game_size).x
onready var actual_cam_pos := global_position


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func _physics_process(delta):
	actual_cam_pos = lerp(actual_cam_pos, player.global_position, delta * 5)
	
	var sub_pixel_position = player.global_position.round() - player.global_position
	
	world.viewport_container.material.set_shader_param("cam_offset", sub_pixel_position)
	
	global_position = player.global_position.round()

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
#	self.global_position = player.global_position
