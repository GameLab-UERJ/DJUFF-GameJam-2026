extends CharacterBody2D
class_name Enemy


@export var health : int


func take_damage() -> void:
	health -= 1
	
	if health == 0:
		die()


func die() -> void:
	queue_free()
