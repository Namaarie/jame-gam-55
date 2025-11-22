extends State

@onready var player: Player = get_parent().get_parent() as Player 

func on_state_entered() -> void:
	pass

func on_state_exited() -> void:
	pass

# func on_state_physics_process(delta: float) -> void:
# 	($DashTimer as Timer).start(dash_cooldown)
# 	var dir := global_position.direction_to(get_global_mouse_position())
# 	($DashTrail as GPUParticles2D).emitting = true
# 	velocity = dir.normalized() * dash_strength / delta

# 	cur_state = $States/Dashing

# 	move_and_slide()

# 	elapsed_dash_frames += 1
# 	if elapsed_dash_frames >= dash_duration_frames:
# 		elapsed_dash_frames = 0
# 		($DashTrail as GPUParticles2D).emitting = false
# 		enter_idle_state()
