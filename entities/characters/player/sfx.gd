extends Node2D

@onready var jump_sfx = $jump_sfx
@onready var dash_sfx = $dash_sfx
@onready var attack_sfx = $attack_sfx
@onready var hurt_sfx = $hurt_sfx

func _ready():
	var player = get_parent()  # the Player node

	player.player_jumped.connect(_on_player_jumped)
	player.player_dashed.connect(_on_player_dashed)
	player.player_attacked.connect(_on_player_attacked)

func _on_player_jumped():
	jump_sfx.play()

func _on_player_dashed():
	if not dash_sfx.playing:
		dash_sfx.play()

func _on_player_attacked():
	attack_sfx.play()
