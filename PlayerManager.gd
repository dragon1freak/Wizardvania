extends Node

var TOGGLE_STATES : bool = false

var HAS_ALT_JUMP : bool = true
var HAS_ALT_MOVE : bool = true

var HAS_AIR : bool = true
var HAS_FIRE : bool = true
var HAS_ICE : bool = true

var player : Player = null

func set_toggle_states(value : bool) -> void:
	self.TOGGLE_STATES = value
	if player != null:
		player.TOGGLE_STATES = value
