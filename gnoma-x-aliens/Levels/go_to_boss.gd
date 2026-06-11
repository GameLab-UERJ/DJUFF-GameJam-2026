extends Area2D



func _on_body_entered(_body: Node2D) -> void:
	EasyTransition.transition_to_path("res://Levels/boss_fight.tscn",1,EasyTransition.TransitionAnim.BLUR)
