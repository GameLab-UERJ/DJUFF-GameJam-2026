extends Node2D

var gameplay_music = load("uid://ckeqdcnpilov6")

@onready var hp_hud: CanvasLayer = $HP_HUD
@onready var player: Player = $Player
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	MenuMusic.stop()
	if name == "JogoInicial":
		Util.current_scene = load("uid://bb0vxy7wwjwik")
		audio_stream_player.play()
		print('here')
	elif name == "BossFight":
		Util.current_scene = load("uid://c81l0hulr32gg")


func game_over() -> void:
	player.just_died()
	

func lost_life() -> void:
	hp_hud.health_change()


func _on_player_died() -> void:
	print("diedededed")
	EasyTransition.transition_to_path("res://menus/defeat_menu/defeat_menu.tscn",1,EasyTransition.TransitionAnim.FADE)
