extends StaticBody2D



var can_interact: bool = false
var dialogue_index: int = 0
var list_limit:int = dialogue_list.size()

@export var dialogue_list: Array[String] = ["hi","hello", "ola"]

@onready var canvas: CanvasLayer = $CanvasLayer
@onready var dialogue_label: Label = $CanvasLayer/Dialogue_Label

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		if dialogue_index < list_limit:
			canvas.visible = true
			get_tree().paused = true
			dialogue_label.text = dialogue_list[dialogue_index]
			dialogue_index += 1
		else:
			canvas.visible = false
			get_tree().paused = false
			dialogue_index = 0
