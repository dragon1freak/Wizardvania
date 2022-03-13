extends Area2D
class_name Trigger

export(NodePath) var target_path : NodePath
onready var target = get_node(target_path) if target_path else null
export(bool) var trigger_on_enter : bool = true
export(float, 0, 10, 0.1) var timer_value : float = 0.0
onready var timer = timer_value

var triggered : bool = false

func _ready():
	var _res = self.connect("body_entered", self, "_trigger_on_body_entered")
	_res = self.connect("body_exited", self, "_trigger_on_body_exited")
	if target.open:
		triggered = true
		$Sprite.frame = 1

func _process(delta):
	if timer_value > 0.0 && triggered:
		timer -= delta
		if timer <= 0.0:
			target.trigger()
			triggered = false
			timer = timer_value

func _trigger_on_body_entered(body) -> void:
	if body is Player && trigger_on_enter && target != null && !triggered && !target.open:
		target.trigger()
		triggered = true
		$Sprite.frame = 1

func _trigger_on_body_exited(body) -> void:
	if body is Player && !trigger_on_enter && target != null && !triggered:
		target.trigger()
		triggered = true
		$Sprite.frame = 1

func reset() -> void:
	self.triggered = false
	self.timer = timer_value
	if target.has_method("reset"):
		target.reset()
	$Sprite.frame = 0

func set_open(object) -> void:
	if object == target:
		triggered = true
		$Sprite.frame = 1
