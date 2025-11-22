extends Node
# useful for updating ui, ui elements can listen to this
signal lifeforce_remaining_updated(remaining_time: float)

# ui elements cal listen to this
signal player_died

# retry
signal restart_level

# quit to main menu
signal quit_to_main_menu

signal start_game
signal start_level(level_number: int)

signal quit_game

signal transition_to_scene(new_scene: PackedScene)

signal advance_level

func _ready() -> void:
	quit_game.connect(on_quit_game)

func on_quit_game() -> void:
	print("quitting game...")
	get_tree().quit()
