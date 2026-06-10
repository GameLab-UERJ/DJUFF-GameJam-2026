extends Control


@export var restart_scene: PackedScene


@onready var retry_button: Button = %RetryButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	if not restart_scene:
		restart_scene = Util.current_scene
	retry_button.pressed.connect(_on_retry_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	retry_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_retry_button_pressed() -> void:
	if not restart_scene:
		return
	get_tree().change_scene_to_packed(restart_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
