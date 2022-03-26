extends Node

var TOGGLE_STATES : bool = false

var HAS_ALT_JUMP : bool = false
var HAS_ALT_MOVE : bool = false

var HAS_AIR : bool = true
var HAS_FIRE : bool = false
var HAS_ICE : bool = false

var HAS_LEFT_GEM : bool = false
var HAS_RIGHT_GEM : bool = false

var player : Player = null

func set_toggle_states(value : bool) -> void:
	self.TOGGLE_STATES = value
	if player != null:
		player.TOGGLE_STATES = value

func set_state(state : String, value : bool = true) -> void:
	self[state] = value
	get_tree().call_group("pickups", "check_state")

func get_save_state() -> Dictionary:
	return {"has_alt_jump": HAS_ALT_JUMP, "has_alt_move": HAS_ALT_MOVE, "has_air": HAS_AIR, "has_fire": HAS_FIRE, "has_ice": HAS_ICE
		,"has_left_gem": HAS_LEFT_GEM, "has_right_gem": HAS_RIGHT_GEM}

func set_save_state(player_state : Dictionary) -> void:
	HAS_ALT_JUMP = player_state["has_alt_jump"]
	HAS_ALT_MOVE = player_state["has_alt_move"]
	HAS_AIR = player_state["has_air"]
	HAS_FIRE = player_state["has_fire"]
	HAS_ICE = player_state["has_ice"]
	HAS_LEFT_GEM = player_state["has_left_gem"]
	HAS_RIGHT_GEM = player_state["has_right_gem"]
	if player:
		player.set_state()
	get_tree().call_group("pickups", "check_state")

func reset_state() -> void:
	HAS_ALT_JUMP = false
	HAS_ALT_MOVE = false
	HAS_FIRE = false
	HAS_ICE = false
	HAS_LEFT_GEM = false
	HAS_RIGHT_GEM = false
