extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var rooms : Array = get_tree().get_nodes_in_group("rooms")
# Called when the node enters the scene tree for the first time.
func _ready():
	draw_minimap()

func fade_out(anim_speed : float = 1.0) -> void:
	$AnimationPlayer.playback_speed = anim_speed / Engine.time_scale
	$AnimationPlayer.play("FadeOut")

func fade_in(anim_speed : float = 1.0) -> void:
	$AnimationPlayer.playback_speed = anim_speed / Engine.time_scale
	$AnimationPlayer.play("FadeIn")

func draw_minimap() -> void:
	_draw()

func _draw():
	for room in rooms:
		var room_rect = room.get_node("TileMap").get_used_rect()
		$GUI/CenterContainer.draw_rect(Rect2(Vector2(100,100), room_rect.size * room.get_node("TileMap").cell_size), Color("#ffffff"))
