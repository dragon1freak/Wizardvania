extends Sprite

export(String) onready var target_pickup : String

var is_active : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func check_state() -> void:
	is_active = PlayerManager[target_pickup]
	if is_active:
		frame = 1
		$Light2D.visible = true
	else:
		frame = 0
		$Light2D.visible = false
