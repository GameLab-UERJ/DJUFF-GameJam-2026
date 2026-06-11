extends Control

const victory_sdx = preload("uid://ci0ne44sryv7q")
const defeat_sdx = preload("uid://24h1naybmfci")

@export var restart_scene: PackedScene


@onready var retry_button: Button = %RetryButton
@onready var quit_button: Button = %QuitButton
@onready var press_audio: AudioStreamPlayer = $PressAudio
@onready var hover_audio: AudioStreamPlayer = $HoverAudio
@onready var theme_audio: AudioStreamPlayer = $ThemeAudio



func _ready() -> void:
	if not restart_scene:
		restart_scene = Util.current_scene
	retry_button.pressed.connect(_on_retry_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	retry_button.grab_focus()
	
	
	if name == "VictoryMenu":
		theme_audio.stream = victory_sdx
	else:
		theme_audio.stream = defeat_sdx
	
	theme_audio.play()

func _on_mouse_entered() -> void:
	if hover_audio == null:
		return
	
	hover_audio.play()
	await hover_audio.finished


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_retry_button_pressed() -> void:
	press_audio.play()
	EasyTransition.transition_to_scene(restart_scene,1,EasyTransition.TransitionAnim.BLUR)


func _on_quit_button_pressed() -> void:
	press_audio.play()
	EasyTransition.transition_to_scene(load("uid://d4b7cvgy38tpi"),1,EasyTransition.TransitionAnim.FADE)
