## This is where entities can be hit
extends Area2D
class_name HurtboxComponent
signal hit_by_hitbox(payload: AbilityStats)

var team: Enums.Teams = Enums.Teams.UNSET

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# enables this hurtbox basically
	monitorable = true
	monitoring = true

func _process(delta: float) -> void:
	var hitboxes: Array[Area2D] = get_overlapping_areas()

	# assuming all areas are hitboxes due to physics layers
	for hitbox: HitboxComponent in hitboxes:
		if hitbox.team == team: continue # don't hit yourself or allies
		# print(hitbox.get_parent().name)
		hit_by_hitbox.emit(hitbox.payload)
