extends Node2D

@onready var hp_hud: CanvasLayer = $HP_HUD
@onready var player: Player = $Player

func _ready() -> void:
	if name == "JogoInicial":
		Util.current_scene = load("uid://bb0vxy7wwjwik")
	elif name == "BossFight":
		Util.current_scene = load("uid://c81l0hulr32gg")


func game_over() -> void:
	EasyTransition.transition_to_path("res://menus/defeat_menu/defeat_menu.tscn",1,EasyTransition.TransitionAnim.FADE)


func lost_life() -> void:
	hp_hud.health_change()
