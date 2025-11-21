extends CharacterBody2D
class_name Character
signal character_died

@export var stats: EntityStats = EntityStats.new()
@export var team: Enums.Teams = Enums.Teams.UNSET
@export var invulerability_frames: int = 30
@export var hitflash_frames: int = 5

var is_invulerable: bool = false
var is_alive: bool = true
var current_invulerability_frames: int = 30
var current_hitflash_frames: int = 20

func _ready() -> void:
	current_invulerability_frames = invulerability_frames
	current_hitflash_frames = hitflash_frames
	($HurtboxComponent as HurtboxComponent).team = team
	($HurtboxComponent as HurtboxComponent).hit_by_hitbox.connect(_on_hurtbox_component_hit_by_hitbox)

func _physics_process(_delta: float) -> void:
	if is_invulerable:
		current_invulerability_frames -= 1
		current_hitflash_frames -= 1
		if current_hitflash_frames < 0:
			current_hitflash_frames = hitflash_frames
			($CharacterSprite as AnimatedSprite2D).modulate = Color(1.0, 1.0, 1.0)
		if current_invulerability_frames < 0:
			is_invulerable = false
			current_invulerability_frames = invulerability_frames

func character_die():
	stats.current_health = 0
	is_alive = false
	print("%s has died." % name)
	character_died.emit()

	queue_free()

func _on_hurtbox_component_hit_by_hitbox(payload: AbilityStats) -> void:
	if is_invulerable: return
	is_invulerable = true
	
	current_invulerability_frames = invulerability_frames
	current_hitflash_frames = hitflash_frames

	($CharacterSprite as AnimatedSprite2D).modulate = Color(18.892, 18.892, 18.892)

	# dealing damage
	stats.current_health -= payload.damage

	print("%s took %d damage, current health: %d" % [name, payload.damage, stats.current_health])

	if stats.current_health <= 0:
		character_die()


