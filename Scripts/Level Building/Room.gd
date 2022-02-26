extends Node2D

export(String) var room_name : String = ""
onready var room_id : String = room_name if room_name != "" else self.name
export(bool) var _has_fire : bool = true
export(bool) var _has_ice : bool = true
export(bool) var _has_air : bool = true

var cam_limits : Dictionary = {}
onready var player_spawn : Vector2 = $PlayerSpawn.global_position

var resetable_children : Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var tilemap = $TileMap
	var tilemap_rect = tilemap.get_used_rect()
	cam_limits.limit_left = tilemap_rect.position.x * tilemap.cell_size.x  + self.global_position.x
	cam_limits.limit_top = tilemap_rect.position.y * tilemap.cell_size.y + self.global_position.y 
	cam_limits.limit_right = cam_limits.limit_left + tilemap_rect.size.x * tilemap.cell_size.x
	cam_limits.limit_bottom = cam_limits.limit_top + tilemap_rect.size.y * tilemap.cell_size.y
	
	var room_detect_shape : CollisionShape2D = $RoomDetect/CollisionShape2D
	room_detect_shape.position = Vector2(cam_limits.limit_right / 2.0, cam_limits.limit_bottom / 2.0)
	room_detect_shape.shape.extents = room_detect_shape.position
	
	for node in get_tree().get_nodes_in_group("resetable"):
		if is_a_parent_of(node):
			resetable_children.push_back(node)
	$Teleporter.set_room_id(self.room_id)

func _on_RoomDetect_body_entered(body):
	if body is Player:
		var element_states : Dictionary = { "has_air": _has_air, "has_fire": _has_fire, "has_ice": _has_ice }
		body.handle_room_enter(cam_limits, player_spawn, element_states, self)
		print("Theyy in heree")

func reset_room() -> void:
	for child in resetable_children:
		if child.has_method("reset"):
			child.reset()
