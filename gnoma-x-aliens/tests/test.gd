extends Node2D


@onready var gun: Gun = $Gun
@onready var player: Player = $Player


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("shoot"):
		gun.shoot_at(player)
