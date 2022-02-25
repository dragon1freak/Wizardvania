extends StaticBody2D
class_name EnergyDoor

var open : bool = false

func trigger() -> void:
	if open && $SquishChecker.get_overlapping_bodies().size() > 0:
		var player = $SquishChecker.get_overlapping_bodies()[0]
		player.handle_death()
	self.visible = !self.visible
	self.open = !self.open
	self.set_collision_mask_bit(1, false if open else true)

func reset() -> void:
	self.visible = true
	self.open = false
	self.set_collision_mask_bit(1, true)

func load_state(is_open : bool) -> void:
	self.visible = !is_open
	self.open = is_open
	self.set_collision_mask_bit(1, !is_open)

func save_state() -> bool:
	return self.open
