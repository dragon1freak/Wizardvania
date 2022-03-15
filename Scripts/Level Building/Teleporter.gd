extends Area2D
class_name Teleporter

export(bool) var is_entrance : bool = false
export(String) var room_id : String = ""
export(String) var target_room_id : String = ""

var target_teleporter : Teleporter

var is_active : bool = false
var can_teleport : bool = false
var player : Player = null

onready var _animation_player : AnimationPlayer = $AnimationPlayer
onready var teleporters : Array = get_tree().get_nodes_in_group("teleporters")

func activate() -> void:
	is_active = true
	_animation_player.play("Activate")
	$Light2D.visible = true
	yield(_animation_player, "animation_finished")
	_animation_player.play("Active")

func set_new_target(new_target : String) -> void:
	if !self.is_active:
		self.activate()
	self.target_room_id = new_target
	for teleporter in teleporters:
		if teleporter.room_id == target_room_id:
			target_teleporter = teleporter

func set_room_id() -> void:
#	self.room_id = new_room_id
	for teleporter in teleporters:
		if teleporter.room_id == target_room_id:
			target_teleporter = teleporter

func _on_Teleporter_body_entered(body):
	if body is Player:
		if !is_entrance && !is_active:
			self.activate()
			if target_teleporter:
				target_teleporter.set_new_target(self.room_id)
			get_tree().call_group("map_segments", "set_room_completed", self.room_id)
			get_parent().is_completed = true
		if !player:
			player = body
		can_teleport = true
		if is_active:
			$Indicator.visible = true

func _on_Teleporter_body_exited(body):
	if body is Player:
		can_teleport = false
		$Indicator.visible = false

func _process(delta):
	if is_active && can_teleport && Input.is_action_pressed("action") && player && target_teleporter:
		if !is_entrance:
			target_teleporter.set_new_target(room_id)
		player.teleporting = true
		player.motion = Vector2.ZERO
		GUIController.fade_out()
		yield(get_node("/root/GUIController/AnimationPlayer"), "animation_finished")
		player.global_position = target_teleporter.global_position
		player.get_node("Camera2D").smoothing_speed = 20
		yield(get_tree().create_timer(0.1),"timeout")
		player.get_node("Camera2D").smoothing_speed = 5
		player.teleporting = false
		GUIController.fade_in()

func get_save_state() -> Dictionary:
	return {"is_entrance": is_entrance, "is_active": is_active, "target_room_id": target_room_id}

func set_save_state(teleporter_state : Dictionary) -> void:
	if teleporter_state["is_active"]:
		set_new_target(teleporter_state["target_room_id"])
