extends Area2D

export(bool) var crumble_on_exit : bool = true
export(bool) var crumble_on_enter : bool = false
export(float, 0, 10, 0.05) var respawn_time : float = 1.0
export(float, 0, 10, 0.05) var crumble_time : float = 1.0
onready var respawn_timer : float = respawn_time
onready var crumble_timer : float = crumble_time

var crumbling : bool = false
var crumbled : bool = false
onready var collider : CollisionShape2D = $StaticBody2D/CollisionShape2D
onready var sprite : Sprite = $Sprite
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if crumbled && respawn_time > 0.0:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			respawn()
	if crumbling:
		crumble_timer -= delta
		if crumble_timer <= 0.0:
			crumble()

func _on_CrumbleBlock_body_exited(body):
	if body is Player && crumble_on_exit && !crumbled:
		crumble()

func _on_CrumbleBlock_body_entered(body):
	if body is Player && !crumble_on_exit && !crumbled:
		start_crumble()

func start_crumble() -> void:
	crumbling = true
	$AnimationPlayer.playback_speed = $AnimationPlayer.get_animation("Crumbling").length / crumble_time
	$AnimationPlayer.play("Crumbling")

func crumble() -> void:
	$AnimationPlayer.play("Idle")
	sprite.visible = false
	collider.set_deferred("disabled", true)
	crumbled = true
	crumbling = false

func respawn() -> void: 
	sprite.visible = true
	collider.set_deferred("disabled", false)
	crumbled = false
	respawn_timer = respawn_time
	crumble_timer = crumble_time
	if self.get_overlapping_bodies().size() > 0 && self.get_overlapping_bodies()[0] is Player:
		start_crumble()

func reset() -> void:
	self.respawn()
