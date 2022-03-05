extends Node2D

export(String) var room_name : String = ""
onready var room_id : String = room_name if room_name != "" else self.name
export(bool) var _has_fire : bool = true
export(bool) var _has_ice : bool = true
export(bool) var _has_air : bool = true

var is_discovered : bool = false
var is_completed : bool = false
var is_current : bool = false

var cam_limits : Dictionary = {}
onready var player_spawn : Vector2 = $PlayerSpawn.global_position

var resetable_children : Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.connect("set_save_data", self, "set_save_state")
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
		get_tree().call_group("map_segments", "set_current", self.room_id)
		get_tree().call_group("rooms", "set_current", self.room_id)
		self.is_discovered = true

func set_current(room : String) -> void:
	if room_id == room:
		self.is_current = true
	else:
		self.is_current = false

func reset_room() -> void:
	for child in resetable_children:
		if child.has_method("reset"):
			child.reset()

func get_save_state() -> Dictionary:
	var room_state : Dictionary = {"room_id": room_id, "is_discovered": is_discovered, "is_completed": is_completed, "is_current": is_current}
	return room_state

func set_save_state(room_name : String, room_state : Dictionary) -> void:
	if room_name == self.room_id:
		self.is_discovered = bool(room_state["is_discovered"])
		self.is_current = bool(room_state["is_current"])
		self.is_completed = bool(room_state["is_completed"])
		if self.is_discovered:
			get_tree().call_group("map_segments", "set_room_discovered", self.room_id)
		if self.is_current:
			get_tree().get_nodes_in_group("player")[0].global_position = self.get_node("PlayerSpawn").global_position
			get_tree().call_group("map_segments", "set_current", self.room_id)
		if self.is_completed:
			get_tree().call_group("map_segments", "set_room_completed", self.room_id)

		if get_parent().has_method("room_is_ready"):
			get_parent().room_is_ready()
