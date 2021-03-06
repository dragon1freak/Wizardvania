extends KinematicBody2D
class_name PlatformerController

# The path to the character's Sprite node, defaults to 'get_node("Sprite")'
var PLAYER_SPRITE
onready var _sprite : Sprite = get_node(PLAYER_SPRITE) if PLAYER_SPRITE else $Sprite

# The path to the character's AnimationPlayer node, defaults to 'get_node("AnimationPlayer")'
var ANIMATION_PLAYER
onready var _animation_player : AnimationPlayer = get_node(ANIMATION_PLAYER) if ANIMATION_PLAYER else $AnimationPlayer

# Input Map actions related to each movement direction, jumping, and sprinting.  Set each to their related 
# action's name in your Input Mapping or create actions with the default names.
var ACTION_UP : String = "up"
var ACTION_DOWN : String = "down"
var ACTION_LEFT : String = "left"
var ACTION_RIGHT : String = "right"
var ACTION_JUMP : String = "jump"
var ACTION_SPRINT : String = "alt_move"

# The following float values are in px/sec when used in movement calculations with 'delta'
# How fast the character gets to the MAX_SPEED value
export(float, 0, 1000, 0.1) var ACCELERATION : float = 500
# The overall cap on the character's speed
export(float, 0, 1000, 0.1) var MAX_SPEED : float = 100
# How fast the character's speed goes back to zero when not moving
export(float, 0, 1000, 0.1) var FRICTION : float = 500
# How fast the character's speed goes back to zero when not moving in the air
export(float, 0, 1000, 0.1) var AIR_RESISTENCE : float = 200
# The speed of the jump when leaving the ground
export(float, 0, 1000, 0.1) var JUMP_FORCE : float = 200
# How fast the character's vertical speed goes back to zero when cancelling a jump
export(float, 0, 1000, 0.1) var JUMP_CANCEL_FORCE : float = 800
# The speed of gravity applied to the character
export(float, 0, 1000, 0.1) var GRAVITY : float = 500

# How long in seconds after walking off a platform the character can still jump, set this to zero to disable it
var COYOTE_TIMER : float = 0.08
# How long in seconds before landing should the game still accept the Jump command, set this to zero to disable it
var JUMP_BUFFER_TIMER : float = 0.1

# Sprint multiplier, multiplies the MAX_SPEED by this value when sprinting
export(float, 0, 10, 0.1) var SPRINT_MULTIPLIER : float = 1.5

# The four possible character states and the character's current state
enum {IDLE, WALK, JUMP, FALL}
var state : int = IDLE

# The player can sprint when can_sprint is true
onready var can_sprint : bool = false
# The player is sprinting when sprinting is true
var sprinting : bool = false
# The player can jump when can_jump is true
var can_jump : bool = false
# The player should jump when landing if should_jump is true, this is used for the jump_buffering
var should_jump : bool = false
# The player is jumping when jumping is true
var jumping : bool = false

# The character's current motion vector
var motion : Vector2 = Vector2.ZERO
func _physics_process(delta : float) -> void:
	physics_tick(delta)

# Overrideable physics process used by the controller that calls whatever functions should be called
# and any logic that needs to be done on the _physics_process tick
func physics_tick(delta : float) -> void:
	var inputs : Dictionary = handle_inputs()
	handle_jump(delta, inputs.jump_strength, inputs.jump_pressed, inputs.jump_released)
	handle_sprint(inputs.sprint_strength)
	handle_motion(delta, inputs.input_direction)
	manage_animations()
	manage_state()
	
	motion.y += GRAVITY * delta
	if !is_on_floor() && can_jump:
		coyote_time()
	motion = move_and_slide(motion, Vector2.UP)

# Manages the character's current state based on the current motion vector
func manage_state() -> void:
	if motion.y == 0:
		if motion.x == 0:
			state = IDLE
		else:
			state = WALK
	elif motion.y < 0:
		state = JUMP
	else:
		state = FALL

# Manages the character's animations based on the current state and sprite direction based on 
# the current horizontal motion
func manage_animations() -> void:
	if motion.x > 0:
		_sprite.flip_h = false
	elif motion.x < 0:
		_sprite.flip_h = true
	match state:
		IDLE:
			_animation_player.play("Idle")
		WALK:
			_animation_player.play("Walk")
		JUMP:
			_animation_player.play("Jump")
		FALL:
			_animation_player.play("Fall")

# Gets the strength and status of the mapped actions
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

# Gets the X/Y axis movement direction using the input mappings assigned to the ACTION UP/DOWN/LEFT/RIGHT variables
func get_input_direction() -> Vector2:
	var x_dir = Input.get_action_strength(ACTION_RIGHT) - Input.get_action_strength(ACTION_LEFT)
	var y_dir = Input.get_action_strength(ACTION_DOWN) - Input.get_action_strength(ACTION_UP)

	return Vector2(sign(x_dir), sign(y_dir))

# ------------------ Movement Logic ---------------------------------
# Takes delta and the current input direction and either applies the movement or applies friction
func handle_motion(delta : float, input_direction : Vector2 = Vector2.ZERO) -> void:
	if input_direction.x != 0:
		apply_motion(delta, input_direction)
	else:
		apply_friction(delta)

# Applies motion in the current input direction using the ACCELERATION, MAX_SPEED, and SPRINT_MULTIPLIER
func apply_motion(delta : float, move_direction : Vector2) -> void:
	if motion.x != 0 and sign(move_direction.x) != sign(motion.x):
		apply_friction(delta)
	var sprint_strength = SPRINT_MULTIPLIER if sprinting else 1.0
	var final_max_speed = MAX_SPEED * abs(move_direction.x) * sprint_strength
	motion.x += move_direction.x * ACCELERATION * delta * (sprint_strength if is_on_floor() else 1.0)
	motion.x = clamp(motion.x, -final_max_speed, final_max_speed)

# Applies friction to the horizontal axis when not moving using the FRICTION and AIR_RESISTENCE values
func apply_friction(delta : float) -> void:
	var fric = FRICTION * delta * sign(motion.x) * -1 if is_on_floor() else AIR_RESISTENCE * delta * sign(motion.x) * -1
	if abs(motion.x) <= abs(fric):
		motion.x = 0
	else:
		motion.x += fric

# Sets the sprinting variable according to the strength of the sprint input action
func handle_sprint(sprint_strength : float) -> void:
	if sprint_strength != 0 and can_sprint:
		$AnimationPlayer.playback_speed = 1.25
		sprinting = true
	else:
		$AnimationPlayer.playback_speed = 1
		sprinting = false

# ------------------ Jumping Logic ---------------------------------
# Takes delta and the jump action status and strength and handles the jumping logic
func handle_jump(delta : float, jump_strength : float = 0.0, jump_pressed : bool = false, _jump_released : bool = false) -> void:
	if (jump_pressed or should_jump) && can_jump:
		apply_jump()
	elif jump_pressed:
		buffer_jump()
	elif jump_strength == 0 and motion.y < 0:
		cancel_jump(delta)
	if is_on_floor() and motion.y >= 0:
		can_jump = true

# Applies a jump force to the character in the specified direction, defaults to JUMP_FORCE and JUMP_DIRECTIONS.UP
# but can be passed a new force and direction
func apply_jump(jump_force : float = JUMP_FORCE, jump_direction : Vector2 = Vector2.UP) -> void:
	can_jump = false
	should_jump = false
	jumping = true
	motion.y = 0
	motion += jump_force * jump_direction

# If jump is released before reaching the top of the jump the jump is cancelled using the JUMP_CANCEL_FORCE and default
func cancel_jump(delta : float) -> void:
	motion.y -= JUMP_CANCEL_FORCE * sign(motion.y) * delta

# If jump is pressed before hitting the ground, it's buffered using the JUMP_BUFFER_TIMER value and the jump is applied 
# if the character lands before the timer ends
func buffer_jump() -> void:
	should_jump = true
	yield(get_tree().create_timer(JUMP_BUFFER_TIMER),"timeout")
	should_jump = false

# If the character steps off of a platform, they are given an amount of time in the air to still jump using the COYOTE_TIMER value
func coyote_time() -> void:
	yield(get_tree().create_timer(COYOTE_TIMER),"timeout")
	can_jump = false
