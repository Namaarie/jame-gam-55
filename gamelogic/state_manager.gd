class_name StateManager
extends Node

var current_state: State = null

func _init(default_state: State) -> void:
	current_state = default_state

func state_physics_process(delta: float) -> void:
	if current_state != null:
		current_state.on_state_physics_process(delta)

func change_state(new_state: State) -> void:
	if current_state != null:
		current_state.on_state_exited()
		current_state = new_state
		current_state.on_state_entered()