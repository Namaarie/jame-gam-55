extends Node
class_name ComponentSystem
signal hit_by_ability(payload: AbilityStats)

var components: Array = []

func register_component(component: Node) -> void:
	components.append(component)

	# check what type of component it is and register accordingly
	if component is HurtboxComponent:
		var hurtbox: HurtboxComponent = component as HurtboxComponent
		# pass it along lmao
		hurtbox.hit_by_hurtbox.connect(func(payload: AbilityStats) -> void: hit_by_ability.emit(payload))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children: Array = get_children()

	for child: Area2D in children:
		register_component(child)