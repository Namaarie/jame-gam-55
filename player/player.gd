extends CharacterBody2D
signal player_attacked
signal player_died
signal player_dashed
signal player_jumped

@export var coyote_time := 5.1
@export var speed := 300.0
@export var ground_friction := 300.0
@export var air_resistance := 150.0
@export var jump_velocity := 300.0
@export var gravity_multiplier := 2.0
@export var max_variable_jump_frames := 15
@export var dash_strength := 600.0
@export var dash_cooldown := 5.0
@export var wall_climb_strength := 0.5
@export var has_double_jump := false
@export var has_dash := false
@export var input_buffer_frames := 15

var input_buffers := {}
var in_coyote_time := false
var coyote_time_reset := true
var cur_variable_jump_frames := -1
var can_double_jump := false
var can_wall_jump := false

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
	cur_variable_jump_frames = max_variable_jump_frames
	($CoyoteTimer as Timer).timeout.connect(end_coyote_time)
	player_jumped.connect(end_coyote_time)

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

func handle_dash(delta: float) -> void:
	if Input.is_action_just_pressed("secondary") and has_dash and ($DashTimer as Timer).is_stopped():
		# do dash
		player_dashed.emit()
		($DashTimer as Timer).start(dash_cooldown)
		var dir := global_position.direction_to(get_global_mouse_position())
		($DashTrail as GPUParticles2D).emitting = true
		velocity = dir.normalized() * dash_strength / delta

func handle_attack(delta: float) -> void:
	if Input.is_action_just_pressed("primary"):
		# TODO: attack
		player_attacked.emit()

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

func _physics_process(delta: float) -> void:
	update_input_buffer()
		
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

	handle_jump(delta)
	handle_dash(delta)
	handle_attack(delta)

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

	move_and_slide()
