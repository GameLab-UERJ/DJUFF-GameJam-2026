extends Area2D


@export var player : Player


func _on_body_entered(_body: Node2D) -> void:
	player.global_position = player.last_position
	player.take_damage()
