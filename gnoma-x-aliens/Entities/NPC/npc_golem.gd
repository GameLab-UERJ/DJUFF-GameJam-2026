extends StaticBody2D


signal victory


@export var dialogue_resource: DialogueResource
@export var dialogue_title: String
@export var is_final : bool


var can_interact: bool = false


@onready var interact_area: Area2D = $InteractArea


func _ready() -> void:
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		DialogueManager.show_dialogue_balloon(
			dialogue_resource,
			dialogue_title
		)
  #TODO VICTORY

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = false


func _on_victory() -> void:
	EasyTransition.transition_to_path("res://menus/victory_menu/victory_menu.tscn",1,EasyTransition.TransitionAnim.TEXTURE_LUMINANCE)
