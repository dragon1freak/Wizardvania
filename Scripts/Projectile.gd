extends KinematicBody2D
class_name Projectile

var speed : float = 0.0
var direction : Vector2 = Vector2.ZERO
var lifetime : float = 1.0
var type : String = ""

func contruct(speed : float, direction : Vector2, lifetime : float, type : String) -> void:
	self.speed = speed
	self.direction = direction
	self.lifetime = lifetime
	self.type = type

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		hit(collision)
	lifetime -= delta
	if lifetime <= 0.0:
		end_life()

func hit(collision):
	if collision.collider.has_method("projectile_hit"):
		collision.collider.projectile_hit(type)
	queue_free()

func end_life():
	queue_free()
