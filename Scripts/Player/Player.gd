extends PlatformerController
class_name Player

export(bool) var TOGGLE_STATES : bool = false

export(bool) var HAS_ALT_JUMP : bool = false
export(bool) var HAS_ALT_MOVE : bool = false

var HAS_AIR : bool = true
var HAS_FIRE : bool = false
var HAS_ICE : bool = false


export(float, 0, 10, 0.1) var ALT_MOVE_COOLDOWN_TIMER : float = 1.0
# =============== AIR ABILITIES =============================
export(float, 0, 1000, 0.1) var GLIDE_FALL_SPEED : float = 20.0
export(float, 0, 10, 0.01) var GLIDE_TIMER_MAX : float = 1.0
var glide_timer : float = GLIDE_TIMER_MAX
var can_glide : bool = false
var gliding : bool = false
# =============== FIRE ABILITIES ============================= 
var can_double_jump : bool = false

export(float, 0, 1000, 0.1) var DASH_FORCE : float = 200.0
export(float, 0, 1, 0.01) var DASH_TIMER : float = 0.1
var can_dash : bool = false
var dashing : bool = false
# =============== ICE ABILITIES ============================= 
export(float, 0, 1000, 0.1) var WALL_FALL_SPEED : float = 50.0
export(float, 0, 1, 0.01) var WALL_JUMP_TIMER : float = 1.0
var wall_hold_timer : float = WALL_JUMP_TIMER
var WALL_JUMP_COUNT : int = 3
var WALL_JUMP_MAX : int = 3
onready var _left_wall_check : RayCast2D = $LeftWallCheck
onready var _right_wall_check : RayCast2D = $RightWallCheck
var can_wall_jump : bool = false
var can_hold_wall : bool = false
var holding_wall : bool = false

export(float, 0, 1000, 0.1) var SLAM_FORCE : float = 200
var can_slam : bool = false
var slamming : bool = false
# ===========================================================
enum STATES {IDLE, WALK, JUMP, FALL, DASH}
enum ELEMENTS {AIR, FIRE, ICE}
var ELEMENT_STATE : int = ELEMENTS.AIR

var spawn : Vector2
onready var camera : Camera2D = $Camera2D
var entering_room : bool = false
var teleporting : bool = false
var paused : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.player = self
	self.HAS_ALT_JUMP = PlayerManager.HAS_ALT_JUMP
	self.HAS_ALT_MOVE = PlayerManager.HAS_ALT_MOVE
	self.HAS_FIRE = PlayerManager.HAS_FIRE
	self.HAS_ICE = PlayerManager.HAS_ICE
	self.TOGGLE_STATES = PlayerManager.TOGGLE_STATES
	
	spawn = global_position
	can_sprint = false
	if GUIController.player == null:
		GUIController.player = self

func set_state() -> void:
	self.HAS_ALT_JUMP = PlayerManager.HAS_ALT_JUMP
	self.HAS_ALT_MOVE = PlayerManager.HAS_ALT_MOVE
	self.HAS_FIRE = PlayerManager.HAS_FIRE
	self.HAS_ICE = PlayerManager.HAS_ICE
	self.TOGGLE_STATES = PlayerManager.TOGGLE_STATES

func _physics_process(_delta : float) -> void:
	if TOGGLE_STATES: 
		handle_toggle_state()
	else:
		handle_element_state()

func physics_tick(delta : float) -> void:
	if !paused:
		manage_animations()
		manage_state()
		var inputs : Dictionary = handle_inputs()
		if !entering_room && !teleporting:
			handle_alt_jump(delta, inputs.jump_strength, inputs.jump_pressed, inputs.jump_released)
			handle_alt_move(inputs.input_direction, inputs.sprint_strength, inputs.sprint_pressed, inputs.sprint_released)
			handle_motion(delta, inputs.input_direction)

		handle_gravity(delta, inputs.input_direction, inputs.jump_strength)
		if !is_on_floor() && can_jump:
			coyote_time()
		motion = move_and_slide(motion, Vector2.UP)

func handle_gravity(delta : float, input_direction : Vector2, jump_strength : float) -> void:
	match ELEMENT_STATE:
		ELEMENTS.AIR:
			motion.y += GRAVITY * delta
			if gliding && motion.y > 0:
				motion.y = clamp(motion.y, -JUMP_FORCE, GLIDE_FALL_SPEED)
				glide_timer -= delta
			if glide_timer <= 0.0:
				can_glide = false
				gliding = false
		ELEMENTS.FIRE:
			if !dashing:
				motion.y += GRAVITY * delta
		ELEMENTS.ICE:
			if !entering_room && input_direction.x < 0 && _left_wall_check.is_colliding() && can_hold_wall && !is_on_floor():
				holding_wall = true
				motion.y += GRAVITY * delta
				motion.y = clamp(motion.y, -JUMP_FORCE, WALL_FALL_SPEED)
				wall_hold_timer -= delta
			elif !entering_room && input_direction.x > 0 && _right_wall_check.is_colliding() && can_hold_wall && !is_on_floor():
				holding_wall = true
				motion.y += GRAVITY * delta
				motion.y = clamp(motion.y, -JUMP_FORCE, WALL_FALL_SPEED)
				wall_hold_timer -= delta
			else:
				holding_wall = false
				if !slamming:
					motion.y += GRAVITY * delta
			if wall_hold_timer <= 0.0:
				WALL_FALL_SPEED += GRAVITY * delta * 0.25

func handle_element_state() -> void:
	if HAS_FIRE && (Input.is_action_just_pressed("fire_state") || (is_zero_approx(Input.get_action_strength("ice_state")) && Input.get_action_strength("fire_state") > 0)):
		if !gliding && !slamming:
			ELEMENT_STATE = ELEMENTS.FIRE
			if TOGGLE_STATES && ELEMENT_STATE == ELEMENTS.FIRE:
				ELEMENT_STATE = ELEMENTS.AIR
	elif HAS_ICE && (Input.is_action_just_pressed("ice_state") || (is_zero_approx(Input.get_action_strength("fire_state")) && Input.get_action_strength("ice_state") > 0)):
		if !gliding && !dashing:
			ELEMENT_STATE = ELEMENTS.ICE
			if TOGGLE_STATES && ELEMENT_STATE == ELEMENTS.ICE:
				ELEMENT_STATE = ELEMENTS.AIR
	elif HAS_AIR && (!HAS_FIRE || is_zero_approx(Input.get_action_strength("fire_state"))) && (!HAS_ICE || is_zero_approx(Input.get_action_strength("ice_state"))):
		if !dashing && !slamming && !TOGGLE_STATES:
			ELEMENT_STATE = ELEMENTS.AIR

func handle_toggle_state() -> void:
	if HAS_FIRE && (Input.is_action_just_pressed("fire_state")):
		if !gliding && !slamming:
			if ELEMENT_STATE == ELEMENTS.FIRE:
				ELEMENT_STATE = ELEMENTS.AIR
			else:
				ELEMENT_STATE = ELEMENTS.FIRE
	elif HAS_ICE && (Input.is_action_just_pressed("ice_state")):
		if !gliding && !dashing:
			if ELEMENT_STATE == ELEMENTS.ICE:
				ELEMENT_STATE = ELEMENTS.AIR
			else:
				ELEMENT_STATE = ELEMENTS.ICE

func manage_state() -> void:
	if motion.y == 0:
		if motion.x == 0:
			state = STATES.IDLE
		elif !dashing:
			state = STATES.WALK
		else:
			state = STATES.DASH
	elif motion.y < 0:
		state = STATES.JUMP
	else:
		state = STATES.FALL

func manage_animations() -> void:
	match ELEMENT_STATE:
		ELEMENTS.ICE:
			_sprite.modulate = Color(0, 1, 1)
		ELEMENTS.FIRE:
			_sprite.modulate = Color(1, 0, 0)
		ELEMENTS.AIR:
			_sprite.modulate = Color(1, 1, 1)
	match state:
		IDLE:
			_animation_player.play("Idle")
		WALK:
			_animation_player.play("Walk")
		JUMP:
			_animation_player.play("Jump")
		FALL:
			_animation_player.play("Fall")

func handle_motion(delta : float, input_direction : Vector2 = Vector2.ZERO) -> void:
	if !slamming && !dashing && input_direction.x != 0:
		apply_motion(delta, input_direction)
		if abs(motion.x) > MAX_SPEED && !sprinting:
			slow_sprint(delta)
		if input_direction.x > 0:
			_sprite.flip_h = false
		elif input_direction.x < 0:
			_sprite.flip_h = true
	elif !dashing:
		apply_friction(delta)

func slow_sprint(delta : float) -> void:
	var fric = FRICTION * delta * sign(motion.x) * -1 if is_on_floor() else AIR_RESISTENCE * delta * sign(motion.x) * -1
	if abs(motion.x) <= abs(fric):
		motion.x = 0
	else:
		motion.x += fric * 0.25

func apply_motion(delta : float, move_direction : Vector2) -> void:
	if motion.x != 0 and sign(move_direction.x) != sign(motion.x):
		apply_friction(delta)
	var sprint_strength : float = SPRINT_MULTIPLIER if sprinting || abs(motion.x) > MAX_SPEED else 1.0
	var final_max_speed : float = MAX_SPEED * abs(move_direction.x) * sprint_strength
	var final_acc : float = move_direction.x * ACCELERATION * delta * (sprint_strength if is_on_floor() else 1.0)
	motion.x += final_acc if abs(motion.x) <= MAX_SPEED || sprinting else 0.0
	motion.x = clamp(motion.x, -final_max_speed, final_max_speed)

# ================= Alt Jump Logic ============================================

func handle_alt_jump(delta : float, jump_strength : float = 0.0, jump_pressed : bool = false, jump_released : bool = false) -> void:
	match ELEMENT_STATE:
		ELEMENTS.ICE:
			var wall_jump_dir : float = 0.0
			if _left_wall_check.is_colliding() && can_wall_jump:
				holding_wall = true
				wall_jump_dir = 1.0
			elif _right_wall_check.is_colliding() && can_wall_jump:
				holding_wall = true
				wall_jump_dir = -1.0
			else:
				holding_wall = false
			if (jump_pressed or should_jump) && can_jump:
				apply_jump()
			elif (jump_pressed or should_jump) && holding_wall && !slamming:
				apply_wall_jump(wall_jump_dir)
			elif jump_pressed:
				buffer_jump()
			if jump_strength == 0 && jumping and motion.y < 0:
				cancel_jump(delta)
		ELEMENTS.AIR:
			holding_wall = false
			if (jump_pressed or should_jump) && can_jump:
				apply_jump()
			elif jump_pressed:
				if can_glide:
					gliding = true
				buffer_jump()
			elif is_zero_approx(jump_strength) && gliding:
				gliding = false
			if jump_strength == 0 && jumping and motion.y < 0:
				cancel_jump(delta)
		ELEMENTS.FIRE:
			holding_wall = false
			if (jump_pressed or should_jump) && (can_jump || can_double_jump):
				if !can_jump && can_double_jump:
					can_double_jump = false
				apply_jump()
				cancel_dash()
			elif jump_pressed:
				buffer_jump()
				cancel_dash()
			if jump_strength == 0 && jumping and motion.y < 0:
				cancel_jump(delta)
	if is_on_floor() and motion.y >= 0.0:
		if HAS_ALT_JUMP:
			can_double_jump = true
			can_wall_jump = true
			can_hold_wall = true
			WALL_JUMP_COUNT = WALL_JUMP_MAX
			wall_hold_timer = WALL_JUMP_TIMER
			WALL_FALL_SPEED = 0
			can_glide = true
			gliding = false
			glide_timer = GLIDE_TIMER_MAX
		can_jump = true

func apply_wall_jump(wall_jump_dir : float) -> void:
	holding_wall = false
#	WALL_JUMP_COUNT -= 1
#	if WALL_JUMP_COUNT <= 0:
#		can_wall_jump = false
#		WALL_JUMP_COUNT = WALL_JUMP_MAX
	apply_jump(JUMP_FORCE, Vector2(wall_jump_dir, -1).normalized())

# ================= Alt Move Logic ============================================

func handle_alt_move(input_direction : Vector2, sprint_strength : float, sprint_pressed : bool, sprint_released : bool) -> void:
	match ELEMENT_STATE:
		ELEMENTS.AIR:
			if can_sprint:
				handle_sprint(sprint_strength)
		ELEMENTS.FIRE:
			sprinting = false
			if can_dash && sprint_pressed:
				apply_dash(input_direction)
			if is_on_wall() && dashing:
				for i in get_slide_count():
					var collision = get_slide_collision(i) if i <= get_slide_count() else null
					if collision:
						apply_jump(JUMP_FORCE / 2, collision.normal)
						if collision.collider is DashBlocker:
							yield(frame_freeze(0.1, 0.25), "completed")
							collision.collider.handle_break()
							print("Collided with: ", collision.collider.name)
				dashing = false
				var final_max_speed = MAX_SPEED * abs(input_direction.x)
				motion.x = clamp(motion.x, -final_max_speed, final_max_speed)
		ELEMENTS.ICE:
			sprinting = false
			if !is_on_floor() && can_slam && sprint_pressed:
				apply_slam()
			elif slamming && sprint_pressed:
				cancel_slam()
			if slamming && is_on_floor():
				slamming = false 
				apply_jump(JUMP_FORCE / 2)
				for i in get_slide_count():
					var collision = get_slide_collision(i)
					if collision.collider is SlamBlocker:
						yield(frame_freeze(0.1, 0.25), "completed")
						collision.collider.handle_break()
						print("Collided with: ", collision.collider.name)
	if is_on_floor() and motion.y >= 0.0:
		if HAS_ALT_MOVE:
			can_sprint = true
			can_dash = true
			can_slam = true

func apply_dash(input_direction : Vector2) -> void:
	dashing = true
	can_dash = false
	var dash_direction = -1 if _sprite.flip_h else 1
	if input_direction.x != 0:
		dash_direction = input_direction.x
	motion.y = 0
	motion.x += DASH_FORCE * dash_direction
	yield(get_tree().create_timer(DASH_TIMER),"timeout")
	dashing = false
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)

func cancel_dash() -> void:
	dashing = false
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)

func apply_slam() -> void:
	slamming = true
	holding_wall = false
	can_hold_wall = false
	can_slam = false
	motion.x = 0
	apply_jump(SLAM_FORCE, Vector2.DOWN)

func cancel_slam() -> void:
	slamming = false
	motion.y = 0

func alt_move_cooldown() -> void:
	can_sprint = false
	can_slam = false
	can_dash = false
	yield(get_tree().create_timer(ALT_MOVE_COOLDOWN_TIMER),"timeout")
	can_sprint = true
	can_slam = true
	can_dash = true

var current_room : Node2D = null
func handle_death() -> void:
	apply_jump(JUMP_FORCE, Vector2(1 if _sprite.flip_h else -1, -sign(motion.y)))
	frame_freeze()
	GUIController.fade_out()
	yield(get_node("/root/GUIController/AnimationPlayer"), "animation_finished")
	motion = Vector2.ZERO
	if current_room && current_room.has_method("reset_room"):
		current_room.reset_room()
	self.global_position = spawn
	camera.smoothing_speed = 20
	yield(get_tree().create_timer(0.1),"timeout")
	camera.smoothing_speed = 5
	GUIController.fade_in()

func frame_freeze(time_scale : float = 0.1, duration : float = 0.4) -> void:
	Engine.time_scale = time_scale
	yield(get_tree().create_timer(duration * time_scale),"timeout")
	Engine.time_scale = 1.0

func handle_room_enter(cam_limits : Dictionary, player_spawn : Vector2, element_states : Dictionary, new_room : Node2D) -> void:
	entering_room = true
	jumping = false
	
	spawn = player_spawn
	HAS_FIRE = element_states.has_fire && PlayerManager.HAS_FIRE
	HAS_ICE = element_states.has_ice && PlayerManager.HAS_ICE
	self.current_room = new_room

	var horizontal_speed : float = MAX_SPEED * sign(motion.x) if motion.x != 0.0 else 0.0
	var vertical_speed : float = JUMP_FORCE * sign(motion.y) if motion.y != 0.0 else 0.0
	motion = Vector2(horizontal_speed, vertical_speed if abs(global_position.y - cam_limits.limit_bottom) < 16 || abs(global_position.y - cam_limits.limit_bottom) < 16 else motion.y)
	camera.limit_left = cam_limits.limit_left
	camera.limit_top = cam_limits.limit_top
	camera.limit_right = cam_limits.limit_right
	camera.limit_bottom = cam_limits.limit_bottom
	yield(get_tree().create_timer(0.1),"timeout")
	entering_room = false
	
func toggle_pause(pause_state : bool) -> void:
	self.paused = pause_state
	self._animation_player.playback_speed = 0.0 if pause_state else 1.0
