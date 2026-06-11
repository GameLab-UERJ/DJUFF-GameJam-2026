extends Area2D

@onready var end_game: Timer = $EndGame


func _on_body_entered(_body: Node2D) -> void:
	end_game.start()


func _on_end_game_timeout() -> void:
	get_tree().change_scene_to_file("res://UI/Credits/credits.tscn")
