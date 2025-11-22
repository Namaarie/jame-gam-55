extends Area2D


func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	print(body)
	if body is not Player: return

	SignalBus.advance_level.emit()
