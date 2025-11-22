extends Character
class_name Player
signal player_attacked
signal player_dashed
signal player_jumped

@export var coyote_time := 0.1
@export var speed := 100.0
@export var ground_friction := 10.0
@export var air_resistance := 7.0
@export var jump_velocity := 30.0
@export var gravity_multiplier := 10.0
@export var max_variable_jump_frames := 10
@export var dash_strength := 50.0
@export var dash_cooldown := 1.0
@export var dash_duration_frames := 10
@export var wall_climb_strength := 0.75
@export var has_double_jump := false
@export var has_dash := false
@export var input_buffer_frames := 15

@export var lifeforce_seconds: float = 20.0

enum {DASHING, ATTACKING, MOVING, IDLE, JUMPING, FALLING, WALL_CLIMBING, DEAD}
@onready var sprite: AnimatedSprite2D = $CharacterSprite

var normal_attack_ability: PackedScene = preload("../../abilities/player_default_attack/player_default_attack.tscn")

var input_buffers := {}
var in_coyote_time := false
var coyote_time_reset := true
var cur_variable_jump_frames := -1
var can_double_jump := false
var can_wall_jump := false
var elapsed_dash_frames := 0

var cur_state := IDLE

var lifeforce_remaining: float = 0.0

# TODO: Variable jump height (done)
# TODO: double jump (done)
# TODO: tune player physics
# TODO: coyote time (done)
# TODO: input buffering (done)
# TODO: dash (done)
# TODO: attack (need to implement rest of damage and hitbox system)
# TODO: wall jump, wall climb (sorta done)
# TODO: action economy (doing things takes 'time')

func _ready() -> void:
	super._ready()
	cur_variable_jump_frames = max_variable_jump_frames
	($CoyoteTimer as Timer).timeout.connect(end_coyote_time)
	player_jumped.connect(end_coyote_time)

	lifeforce_remaining = lifeforce_seconds

	# hook into lifetimer
	enter_idle_state()

func enter_attack_state() -> void:
	if cur_state == ATTACKING: return
	cur_state = ATTACKING
	sprite.play("normal_attack")
	update_state_text()

func enter_dash_state() -> void:
	if cur_state == DASHING: return
	cur_state = DASHING
	sprite.play("dash")
	update_state_text()

func enter_idle_state() -> void:
	if cur_state == IDLE: return
	cur_state = IDLE
	sprite.play("hurt")
	update_state_text()

func start_coyote_time() -> void:
	if coyote_time_reset:
		in_coyote_time = true
		($CoyoteTimer as Timer).start(coyote_time)

func end_coyote_time() -> void:
	in_coyote_time = false
	coyote_time_reset = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: return

	input_buffers[event.as_text()] = input_buffer_frames

func apply_dash(delta: float) -> void:
	# do dash
	player_dashed.emit()

	($DashTimer as Timer).start(dash_cooldown)
	var dir := global_position.direction_to(get_global_mouse_position())
	($DashTrail as GPUParticles2D).emitting = true
	velocity = dir.normalized() * dash_strength / delta

	cur_state = DASHING

	move_and_slide()

func update_state_text() -> void:
	match cur_state:
		DASHING:
			$Label.text = "State DASHING"
		ATTACKING:
			$Label.text = "State ATTACKING"
		MOVING:
			$Label.text = "State MOVING"
		IDLE:
			$Label.text = "State IDLE"
		JUMPING:
			$Label.text = "State JUMPING"
		FALLING:
			$Label.text = "State FALLING"
		WALL_CLIMBING:
			$Label.text = "State WALL_CLIMBING"

func handle_jump(delta: float) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or in_coyote_time or can_double_jump or can_wall_jump):
		# jump event
		player_jumped.emit()
		
		cur_variable_jump_frames = max_variable_jump_frames
		
		# double jump if we're not on floor and can double jump
		if can_double_jump and !is_on_floor() and !is_on_wall():
			can_double_jump = false
			
		# wall jumping
		if can_wall_jump and is_on_wall_only():
			can_wall_jump = false
		
		# if jump was made in coyote time, then end coyote time
		if in_coyote_time:
			end_coyote_time()
		
		# update velocity for jump
		velocity.y = -(jump_velocity / delta)

func hit_ground() -> void:
	# reset coyote time if is on floor
	coyote_time_reset = true
	can_wall_jump = false
	if has_double_jump:
		can_double_jump = true
	cur_variable_jump_frames += 1
	if cur_variable_jump_frames > max_variable_jump_frames:
		cur_variable_jump_frames = max_variable_jump_frames

func update_input_buffer() -> void:
	# update input buffer
	for input: String in input_buffers:
		input_buffers[input] -= 1
		if input_buffers[input] < 0:
			input_buffers.erase(input)

func update_lifeforce(delta: float) -> void:
	if lifeforce_remaining <= 0.0: return
	lifeforce_remaining -= delta
	SignalBus.lifeforce_remaining_updated.emit(lifeforce_remaining)
	if lifeforce_remaining <= 0.0:
		lifeforce_remaining = 0.0
		# ran out of lifeforce, die
		player_die()

func _physics_process(delta: float) -> void:
	if not is_alive: return
	super._physics_process(delta)

	update_lifeforce(delta)
	update_input_buffer()

	if cur_state == DASHING:
		apply_dash(delta)
		
		elapsed_dash_frames += 1
		if elapsed_dash_frames >= dash_duration_frames:
			elapsed_dash_frames = 0
			($DashTrail as GPUParticles2D).emitting = false
			enter_idle_state()
		return
	
	if cur_state == ATTACKING:
		# don't process movement while attacking
		move_and_slide()
		return

	if is_on_floor():
		hit_ground()
		velocity = velocity.move_toward(Vector2.ZERO, ground_friction * delta * velocity.length())
	else:
		# Add the gravity.
		velocity += get_gravity() * delta * gravity_multiplier
		velocity = velocity.move_toward(Vector2.ZERO, air_resistance * delta * velocity.length())

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x += direction * speed

	if Input.is_action_just_pressed("secondary") and has_dash and ($DashTimer as Timer).is_stopped():
		enter_dash_state()
		return

	if Input.is_action_just_pressed("primary"):
		enter_attack_state()
		return

	handle_jump(delta)

	# logic applied based on x velocity
	if velocity.x > 0:
		# when player moving right
		($CharacterSprite as AnimatedSprite2D).flip_h = false
	elif velocity.x < 0:
		# when player moving left
		($CharacterSprite as AnimatedSprite2D).flip_h = true
	else:
		# when player not moving horizontally
		pass

	# logic applied based on y velocity
	if velocity.y > 0:
		# if falling, start counting down coyote time
		start_coyote_time()
		
		# wall climbing
		if is_on_wall():
			var wall_dir := signf(get_wall_normal().x) * -1.0
			if sign(direction) == wall_dir:
				velocity.y *= wall_climb_strength
				can_wall_jump = true
			else:
				can_wall_jump = false
	elif velocity.y < 0:
		# jumping/climbing
		if Input.is_action_pressed("jump") and cur_variable_jump_frames > 0:
			cur_variable_jump_frames -= 1
			velocity -= get_gravity() * delta * gravity_multiplier
	else:
		# if velocity.y = 0, not moving
		pass

	# state switching
	if velocity.x != 0:
		cur_state = MOVING
	else:
		enter_idle_state()
	
	if velocity.y > 0 and not is_on_floor():
		cur_state = FALLING
	elif velocity.y < 0 and not is_on_floor():
		cur_state = JUMPING

	update_state_text()
	match cur_state:
		MOVING:
			if is_on_floor():
				sprite.animation = "run"
		JUMPING:
			sprite.animation = "jump"
		FALLING:
			sprite.animation = "fall"
		WALL_CLIMBING:
			sprite.animation = "wall_climb"
		IDLE:
			sprite.animation = "hurt"
		ATTACKING:
			sprite.animation = "normal_attack"
		DEAD:
			sprite.animation = "die" 

	move_and_slide()

func player_die() -> void:
	is_alive = false
	SignalBus.player_died.emit()


func _on_character_sprite_animation_finished() -> void:
	if sprite.animation == "normal_attack":
		enter_idle_state()


func _on_character_sprite_animation_looped() -> void:
	pass # Replace with function body.


func _on_character_sprite_frame_changed() -> void:
	if sprite == null: return
	if sprite.animation == "normal_attack":
		if sprite.frame == 1:
			var instance: Node2D = normal_attack_ability.instantiate()
			get_parent().add_child(instance)
			instance.global_position = global_position

			if sprite.flip_h == false:
				instance.scale = Vector2(-1, 1)

			player_attacked.emit()

	pass # Replace with function body.
