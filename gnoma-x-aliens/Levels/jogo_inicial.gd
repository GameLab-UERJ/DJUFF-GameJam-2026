extends Node2D

const gameplay_music = preload("uid://ckeqdcnpilov6")

@onready var hp_hud: CanvasLayer = $HP_HUD
@onready var player: Player = $Player

func _ready() -> void:
	if name == "JogoInicial":
		Util.current_scene = load("uid://bb0vxy7wwjwik")
		MenuMusic.play_scene_music(gameplay_music, -10)
	elif name == "BossFight":
		Util.current_scene = load("uid://c81l0hulr32gg")
		MenuMusic.stop()


func game_over() -> void:
	player.just_died()
	

func lost_life() -> void:
	hp_hud.health_change()


func _on_player_died() -> void:
	print("diedededed")
	EasyTransition.transition_to_path("res://menus/defeat_menu/defeat_menu.tscn",1,EasyTransition.TransitionAnim.FADE)
