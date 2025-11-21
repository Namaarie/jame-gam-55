extends Node

@export var main_menu_scene: PackedScene = preload("res://ui/main_menu/main_menu.tscn")
@export var splash_screen: PackedScene = preload("res://ui/splashscreen/splash_screen.tscn")
@export var settings_scene: PackedScene
@export var current_level: int = 0

func _ready() -> void:
	SignalBus.quit_to_main_menu.connect(quit_to_main_menu)
	SignalBus.restart_level.connect(restart_level)
	SignalBus.start_game.connect(start_game)
	SignalBus.transition_to_scene.connect(transition_to_scene)
	SignalBus.advance_level.connect(advance_level)

	var splash_screen_instance := splash_screen.instantiate()
	splash_screen_instance.splash_screen_timeout.connect(after_splash_screen)
	add_child.call_deferred(splash_screen_instance)

func transition_to_scene(new_scene: PackedScene) -> void:
	var children = get_children()
	for child in children:
		if child != Node:
			child.queue_free()
	var new_scene_instance := new_scene.instantiate()
	add_child.call_deferred(new_scene_instance)

func advance_level() -> void:
	current_level += 1
	print("advancing to level %d" % current_level)
	transition_to_scene(load("res://levels/level_%d.tscn" % current_level))

func start_game() -> void:
	current_level = 1
	print("starting game at level %d" % current_level)
	transition_to_scene(load("res://levels/level_%d.tscn" % current_level))

func after_splash_screen() -> void:
	transition_to_scene(main_menu_scene)

func quit_to_main_menu() -> void:
	transition_to_scene(main_menu_scene)

func restart_level() -> void:
	get_tree().reload_current_scene()
