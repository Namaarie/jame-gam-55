extends Control

@export var start_button: TextureButton
@export var settings_button: TextureButton
@export var quit_button: TextureButton

func _ready() -> void:
	start_button.pressed.connect(on_start_button_pressed)
	settings_button.pressed.connect(on_settings_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	bgm_manager.stop_music()

func on_start_button_pressed() -> void:
	SignalBus.start_game.emit()

func on_settings_button_pressed() -> void:
	print("Settings button pressed - not implemented yet")

func on_quit_button_pressed() -> void:
	SignalBus.quit_game.emit()
