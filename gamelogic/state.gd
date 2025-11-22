class_name State
extends Node

var on_entered: Callable
var on_exited: Callable
var on_physics_process: Callable

func _init(entered: Callable, exited: Callable, update: Callable) -> void:
	on_entered = entered
	on_exited = exited
	on_physics_process = update