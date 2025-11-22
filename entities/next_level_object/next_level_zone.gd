extends Area2D


func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	
	var player = body as Player
	if player == null: return
	print(player)
	SignalBus.advance_level.emit()
