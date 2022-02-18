extends Projectile
class_name Firebolt

func contruct(speed : float, direction : Vector2, lifetime : float, _type : String) -> void:
	self.speed = speed
	self.direction = direction
	self.lifetime = lifetime
	self.type = type

# Called when the node enters the scene tree for the first time.
func _ready():
	self.type = "firebolt"

