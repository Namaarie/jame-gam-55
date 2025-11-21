extends Control

@export var life_timer_label: RichTextLabel
@export var death_screen: Control
@export var restart_button: TextureButton
@export var quit_button: TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.lifeforce_remaining_updated.connect(update_dislay)
	SignalBus.player_died.connect(enable_death_screen)
	restart_button.pressed.connect(func() -> void: SignalBus.restart_level.emit())
	quit_button.pressed.connect(func() -> void: SignalBus.quit_to_main_menu.emit())

func enable_death_screen() -> void:
	death_screen.visible = true

func hide_death_screen() -> void:
	death_screen.visible = false

func update_dislay(remaining: float) -> void:
	life_timer_label.text = "Time Left: %.2f" % [remaining]
