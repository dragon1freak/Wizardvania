extends Node2D

export(String) var room_name : String = ""
onready var room_id : String = room_name if room_name != "" else self.name
export(bool) var is_challenge_room : bool = false

export(bool) var _has_fire : bool = true
export(bool) var _has_ice : bool = true
export(bool) var _has_air : bool = true

var is_discovered : bool = false
var is_completed : bool = false
var is_current : bool = false

var cam_limits : Dictionary = {}
onready var player_spawn : Vector2 = $PlayerSpawn.global_position

var resetable_children : Array = []
var teleporters : Array = []
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
	var extents_size : Vector2 = Vector2((cam_limits.limit_right - cam_limits.limit_left) / 2.0, ((cam_limits.limit_bottom - cam_limits.limit_top) / 2.0))
	room_detect_shape.position = Vector2(extents_size.x + (tilemap_rect.position.x * tilemap.cell_size.x), extents_size.y  + (tilemap_rect.position.y * tilemap.cell_size.y))
	room_detect_shape.shape.extents = extents_size
	
	for node in get_tree().get_nodes_in_group("resetable"):
		if is_a_parent_of(node):
			resetable_children.push_back(node)
	for node in get_tree().get_nodes_in_group("teleporters"):
		if is_a_parent_of(node):
			teleporters.push_back(node)
	if self.get_node_or_null("Teleporter"):
		$Teleporter.set_room_id()
	if self.get_node_or_null("Teleporter2"):
		$Teleporter2.set_room_id()

func _on_RoomDetect_body_entered(body):
	if body is Player:
		var element_states : Dictionary = { "has_air": _has_air, "has_fire": _has_fire, "has_ice": _has_ice }
		body.handle_room_enter(cam_limits, player_spawn, element_states, self)
		get_tree().call_group("map_segments", "set_current", self.room_id)
		get_tree().call_group("rooms", "set_current", self.room_id)
		self.is_discovered = true
		if $PlayerSpawn.has_method("activate"):
			$PlayerSpawn.activate()

func set_current(room : String) -> void:
	if room_id == room:
		self.is_current = true
		self.visible = true
	else:
		self.visible = false
		self.is_current = false

func reset_room() -> void:
	for child in resetable_children:
		if child.has_method("reset"):
			child.reset()

func get_save_state() -> Dictionary:
	var room_state : Dictionary = {"room_id": room_id, "is_discovered": is_discovered, "is_completed": is_completed, "is_current": is_current, "doors": {}}
	if !is_challenge_room:
		for child in resetable_children:
			if child is EnergyDoor || child is DashBlocker || child is SlamBlocker:
				room_state["doors"][child.name] = child.save_state()
	if self.get_node_or_null("Teleporter"):
		room_state["teleporter_state"] = $Teleporter.get_save_state()
	if self.get_node_or_null("Teleporter2"):
		room_state["teleporter2_state"] = $Teleporter2.get_save_state()
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
		if self.get_node_or_null("Teleporter"):
			$Teleporter.set_save_state(room_state["teleporter_state"])
		if self.get_node_or_null("Teleporter2"):
			$Teleporter2.set_save_state(room_state["teleporter2_state"])
		if !is_challenge_room:
				for child in resetable_children:
					if child is EnergyDoor || child is DashBlocker || child is SlamBlocker:
						child.load_state(room_state["doors"][child.name])
		if get_tree().get_nodes_in_group("world")[0].has_method("room_is_ready"):
			get_tree().get_nodes_in_group("world")[0].room_is_ready()
