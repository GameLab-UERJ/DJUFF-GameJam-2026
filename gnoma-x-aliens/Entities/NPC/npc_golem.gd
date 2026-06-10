extends StaticBody2D


signal victory

@export var is_final : bool
@export var dialogue_list: Array[String] = ["hi", "hello", "ola"]


var can_interact: bool = false
var dialogue_index: int = 0


@onready var canvas: CanvasLayer = $CanvasLayer
@onready var dialogue_label: Label = $CanvasLayer/Dialogue_Label
@onready var interact_area: Area2D = $InteractArea


func _ready() -> void:
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	canvas.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if dialogue_index < dialogue_list.size():
			canvas.visible = true
			get_tree().paused = true
			dialogue_label.text = dialogue_list[dialogue_index]
			dialogue_index += 1
		else:
			canvas.visible = false
			get_tree().paused = false
			dialogue_index = 0
			if is_final:
				victory.emit()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = false
		canvas.visible = false
		get_tree().paused = false
		dialogue_index = 0


func _on_victory() -> void:
	EasyTransition.transition_to_path("res://menus/victory_menu/victory_menu.tscn",1,EasyTransition.TransitionAnim.TEXTURE_LUMINANCE)
