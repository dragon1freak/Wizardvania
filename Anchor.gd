extends Position2D

onready var player = get_node("../Player")

func _process(delta):
	var target = player.global_position
	var target_x = int(lerp(global_position.x, target.x, 0.2))
	var target_y = int(lerp(global_position.y, target.y, 0.2))
	global_position = Vector2(target_x, target_y)
