extends Control

@onready var restart_button = $restart_button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bgm_manager.stop_music() 
	restart_button.pressed.connect(func() -> void: SignalBus.quit_to_main_menu.emit())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
