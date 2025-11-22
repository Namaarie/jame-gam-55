extends Control


@onready var level_bgm = $level_bgm
@onready var boss_bgm = $boss_bgm

var current_track: String = ""

func play_level_music():
	if not level_bgm.playing:
		level_bgm.play()

func play_boss_music():
	level_bgm.stop()
	boss_bgm.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
