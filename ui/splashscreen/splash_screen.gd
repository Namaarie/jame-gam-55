extends Control
signal splash_screen_timeout

@export var splash_screen_duration: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(splash_screen_duration).timeout
	splash_screen_timeout.emit()
