extends CharacterBody2D

@export var ability_stats: AbilityStats = AbilityStats.new()
@export var team: Enums.Teams = Enums.Teams.UNSET

func _init() -> void:
	assert(ability_stats != null)

func _ready() -> void:
	($HitboxComponent as HitboxComponent).team = team
	($HitboxComponent as HitboxComponent).payload = ability_stats
