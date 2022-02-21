extends StaticBody2D
class_name EnergyDoor

var open : bool = false

func trigger() -> void:
	if open && $SquishChecker.get_overlapping_bodies().size() > 0:
		var player = $SquishChecker.get_overlapping_bodies()[0]
		player.handle_death()
	self.visible = !self.visible
	open = !open
	self.set_collision_mask_bit(1, false if open else true)
