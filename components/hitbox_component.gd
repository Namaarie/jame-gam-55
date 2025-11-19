## This is where entites do damage
extends Area2D
class_name HitboxComponent

var team: Enums.Teams = Enums.Teams.UNSET

var payload: AbilityStats = AbilityStats.new()

func _ready() -> void:
	# enables this hitbox basically
	monitorable = true
	monitoring = true