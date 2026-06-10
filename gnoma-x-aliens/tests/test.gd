extends Node2D


@onready var player: Player = $Player
@onready var boss: Node = $Jogo_inicial/Boss


func _ready() -> void:
	player.player_died.connect(_on_player_died)
	boss.boss_died.connect(_on_boss_died)


func _on_player_died() -> void:
	get_tree().change_scene_to_file("res://menus/defeat_menu/defeat_menu.tscn")


func _on_boss_died() -> void:
	get_tree().change_scene_to_file("res://menus/victory_menu/victory_menu.tscn")
