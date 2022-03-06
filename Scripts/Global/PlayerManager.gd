extends Node

var TOGGLE_STATES : bool = false

var HAS_ALT_JUMP : bool = false
var HAS_ALT_MOVE : bool = false

var HAS_AIR : bool = true
var HAS_FIRE : bool = false
var HAS_ICE : bool = false

var player : Player = null

func set_toggle_states(value : bool) -> void:
	self.TOGGLE_STATES = value
	if player != null:
		player.TOGGLE_STATES = value

func get_save_state() -> Dictionary:
	return {"has_alt_jump": HAS_ALT_JUMP, "has_alt_move": HAS_ALT_MOVE, "has_air": HAS_AIR, "has_fire": HAS_FIRE, "has_ice": HAS_ICE}

func set_save_state(player_state : Dictionary) -> void:
	HAS_ALT_JUMP = player_state["has_alt_jump"]
	HAS_ALT_MOVE = player_state["has_alt_move"]
	HAS_AIR = player_state["has_air"]
	HAS_FIRE = player_state["has_fire"]
	HAS_ICE = player_state["has_ice"]
	if player:
		player.set_state()
	get_tree().call_group("pickups", "check_state")
