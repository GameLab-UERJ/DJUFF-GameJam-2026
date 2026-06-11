extends StaticBody2D


signal victory


@export var dialogue_resource: DialogueResource
@export var dialogue_title: String
@export var is_final : bool


var can_interact: bool = false

var player: Player

@onready var interact_area: Area2D = $InteractArea
@onready var animation_golem: AnimatedSprite2D = $Animation_Golem
@onready var hint: Label = $Hint


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	animation_golem.material = ShaderMaterial.new()
	animation_golem.material.shader = preload("uid://i8xl186i1o18")
	animation_golem.material.set("shader_parameter/outline_color",Color.AQUAMARINE)
	
	player = get_tree().get_first_node_in_group("player")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		DialogueManager.show_dialogue_balloon(
			dialogue_resource,
			dialogue_title
		)
		
		player.movement_component.enabled = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = true
		animation_golem.material.set("shader_parameter/width",2)
		hint.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = false
		animation_golem.material.set("shader_parameter/width",0)
		hint.hide()


func _on_victory() -> void:
	EasyTransition.transition_to_path("res://menus/victory_menu/victory_menu.tscn",1,EasyTransition.TransitionAnim.TEXTURE_LUMINANCE)


func _on_dialogue_finished(dialogue : DialogueResource) -> void:
	if is_final:
		_on_victory()
		
	player.movement_component.enabled = true
