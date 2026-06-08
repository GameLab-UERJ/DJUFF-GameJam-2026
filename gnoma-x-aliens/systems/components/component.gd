extends Node
class_name Component


@onready var parent : Node2D = get_parent()


func _ready() -> void:
	if not get_parent():
		push_error("Component has to have a parent")
