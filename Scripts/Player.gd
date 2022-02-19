extends PlatformerController
class_name Player

export(bool) var TOGGLE_STATES : bool = false

export(bool) var HAS_ALT_JUMP : bool = false
export(bool) var HAS_ALT_MOVE : bool = false
export(bool) var HAS_ELEMENT_ACTION : bool = false

export(bool) var HAS_FIRE : bool = false
export(bool) var HAS_ICE : bool = false

export(float, 0, 10, 0.1) var ACTION_COOLDOWN_TIMER : float = 1.0
# =============== AIR ABILITIES =============================
export(float, 0, 1000, 0.1) var GLIDE_FALL_SPEED : float = 20
export(float, 0, 10, 0.01) var GLIDE_TIMER_MAX : float = 1.0
var glide_timer : float = GLIDE_TIMER_MAX
var can_glide : bool = false
var gliding : bool = false

var can_gust : bool = false
# =============== FIRE ABILITIES ============================= 
var can_double_jump : bool = false

export(float, 0, 1000, 0.1) var DASH_FORCE : float = 200
export(float, 0, 1, 0.01) var DASH_TIMER : float = 0.1
var can_dash : bool = false
var dashing : bool = false

var FIREBOLT : PackedScene = preload("res://Scenes/Player/Firebolt.tscn")
var can_firebolt : bool = false
# =============== ICE ABILITIES ============================= 
export(float, 0, 1000, 0.1) var WALL_FALL_SPEED : float = 50
export(float, 0, 10, 0.01) var WALL_JUMP_TIMER : float = 1.0
var wall_hold_timer : float = WALL_JUMP_TIMER
var WALL_JUMP_COUNT : int = 3
var WALL_JUMP_MAX : int = 3
onready var _left_wall_check : RayCast2D = $LeftWallCheck
onready var _right_wall_check : RayCast2D = $RightWallCheck
var can_wall_jump : bool = false
var can_hold_wall : bool = false
var holding_wall : bool = false

export(float, 0, 1000, 0.1) var SLAM_FORCE : float = 200
export(float, 0, 1, 0.01) var SLAM_TIMER : float = 0.1
var can_slam : bool = false
var slamming : bool = false

var can_shell : bool = false
# ===========================================================
enum STATES {IDLE, WALK, JUMP, FALL, DASH}
enum ELEMENTS {AIR, FIRE, ICE}
var ELEMENT_STATE : int = ELEMENTS.AIR

# Called when the node enters the scene tree for the first time.
func _ready():
	element_action_cooldown()
	can_sprint = false
	var tilemap = get_parent().get_node("TileMap")
	var tilemap_rect = tilemap.get_used_rect()
	var camera = $Camera2D
	camera.limit_left = tilemap_rect.position.x * tilemap.cell_size.x
	camera.limit_top = tilemap_rect.position.y * tilemap.cell_size.y
	camera.limit_right = camera.limit_left + tilemap_rect.size.x * tilemap.cell_size.x
	camera.limit_bottom = camera.limit_top + tilemap_rect.size.y * tilemap.cell_size.y

func _physics_process(delta):
	if TOGGLE_STATES: 
		handle_toggle_state()
	else:
		handle_element_state()

func physics_tick(delta : float) -> void:
	var inputs : Dictionary = handle_inputs()
	handle_alt_jump(delta, inputs.jump_strength, inputs.jump_pressed, inputs.jump_released)
	handle_alt_move(inputs.input_direction, inputs.sprint_strength, inputs.sprint_pressed, inputs.sprint_released)
	handle_action(inputs.input_direction, inputs.action_pressed)
	handle_motion(delta, inputs.input_direction)
	manage_animations()
	manage_state()
	
	handle_gravity(delta, inputs.input_direction, inputs.jump_strength)
	
	if !is_on_floor() && can_jump:
		coyote_time()
	motion = move_and_slide(motion, Vector2.UP)

func handle_inputs() -> Dictionary:
	return {
		input_direction = get_input_direction(), 
		jump_strength = Input.get_action_strength(ACTION_JUMP),
		jump_pressed = Input.is_action_just_pressed(ACTION_JUMP), 
		jump_released = Input.is_action_just_released(ACTION_JUMP), 
		sprint_strength = Input.get_action_strength(ACTION_SPRINT),
		sprint_pressed = Input.is_action_just_pressed(ACTION_SPRINT),
		sprint_released = Input.is_action_just_released(ACTION_SPRINT),
		action_strength = Input.get_action_strength("action"),
		action_pressed = Input.is_action_just_pressed("action"),
		action_released = Input.is_action_just_released("action"),
		}

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
			if input_direction.x < 0 && _left_wall_check.is_colliding() && can_hold_wall:
				holding_wall = true
				motion.y += GRAVITY * delta
				motion.y = clamp(motion.y, -JUMP_FORCE, WALL_FALL_SPEED)
				wall_hold_timer -= delta
			elif input_direction.x > 0 && _right_wall_check.is_colliding() && can_hold_wall:
				holding_wall = true
				motion.y += GRAVITY * delta
				motion.y = clamp(motion.y, -JUMP_FORCE, WALL_FALL_SPEED)
				wall_hold_timer -= delta
			else:
				holding_wall = false
				if !slamming:
					motion.y += GRAVITY * delta
			if wall_hold_timer <= 0.0:
				can_hold_wall = false
				can_wall_jump = false

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
	elif (!HAS_FIRE || is_zero_approx(Input.get_action_strength("fire_state"))) && (!HAS_ICE || is_zero_approx(Input.get_action_strength("ice_state"))):
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
	if motion.x > 0:
		_sprite.flip_h = false
	elif motion.x < 0:
		_sprite.flip_h = true
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
			if jump_strength == 0 and motion.y < 0:
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
			if jump_strength == 0 and motion.y < 0:
				cancel_jump(delta)
		ELEMENTS.FIRE:
			holding_wall = false
			if (jump_pressed or should_jump) && (can_jump || can_double_jump):
				if !can_jump && can_double_jump:
					can_double_jump = false
				apply_jump()
			elif jump_pressed:
				buffer_jump()
			if jump_strength == 0 and motion.y < 0:
				cancel_jump(delta)
	if is_on_floor() and motion.y >= 0.0:
		if HAS_ALT_JUMP:
			can_double_jump = true
			can_wall_jump = true
			can_hold_wall = true
			WALL_JUMP_COUNT = WALL_JUMP_MAX
			wall_hold_timer = WALL_JUMP_TIMER
			can_glide = true
			gliding = false
			glide_timer = GLIDE_TIMER_MAX
		can_jump = true

func apply_wall_jump(wall_jump_dir : float) -> void:
	holding_wall = false
	WALL_JUMP_COUNT -= 1
	if WALL_JUMP_COUNT <= 0:
		can_wall_jump = false
		WALL_JUMP_COUNT = WALL_JUMP_MAX
	apply_jump(JUMP_FORCE, Vector2(wall_jump_dir, -2).normalized())

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
			if is_on_wall():
				dashing = false
				var final_max_speed = MAX_SPEED * abs(input_direction.x)
				motion.x = clamp(motion.x, -final_max_speed, final_max_speed)
		ELEMENTS.ICE:
			sprinting = false
			if !is_on_floor() && can_slam && sprint_pressed:
				apply_slam()
			elif slamming && sprint_pressed:
				cancel_slam()
	if is_on_floor() and motion.y >= 0.0:
		if HAS_ALT_MOVE:
			can_sprint = true
			can_dash = true
			can_slam = true
			slamming = false

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
	var final_max_speed = MAX_SPEED * abs(input_direction.x)
	motion.x = clamp(motion.x, -final_max_speed, final_max_speed)

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

# ================= Element Action Logic ============================================

func handle_action(input_direction : Vector2, action_pressed : bool) -> void:
	if action_pressed:
		match ELEMENT_STATE:
			ELEMENTS.AIR:
				if can_gust:
					if is_zero_approx(input_direction.y):
						print("whoosh")
					else:
						print("whoosh in " + str(input_direction.y))
					element_action_cooldown()
			ELEMENTS.FIRE:
				if can_firebolt:
					if is_zero_approx(input_direction.x):
						print("burning")
					else:
						print("burning in " + str(input_direction.x))
					element_action_cooldown()
			ELEMENTS.ICE:
				if can_shell:
					if is_zero_approx(input_direction.x) && is_zero_approx(input_direction.y):
						print("protect me cone")
					elif !is_zero_approx(input_direction.x):
						print("shell to the hor " + str(input_direction.x))
					elif !is_zero_approx(input_direction.y):
						print("shell to the vert " + str(input_direction.y))
					element_action_cooldown()

func element_action_cooldown() -> void:
	can_gust = false
	can_firebolt = false
	can_shell = false
	yield(get_tree().create_timer(ACTION_COOLDOWN_TIMER),"timeout")
	can_gust = true
	can_firebolt = true
	can_shell = true
