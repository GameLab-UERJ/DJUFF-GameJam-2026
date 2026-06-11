extends Area2D

@onready var end_game: Timer = $EndGame

func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print('oi')
	end_game.start()


func _on_end_game_timeout() -> void:
	print('xau')
	get_tree().change_scene_to_file("res://UI/Credits/credits.tscn")
