extends Character

@export var contact_damage: float = 10.0

func _ready() -> void:
	super._ready()
	($HitboxComponent as HitboxComponent).team = team
	($HitboxComponent as HitboxComponent).payload.damage = contact_damage