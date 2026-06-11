extends Control


var aliens: String = "[wave amp=50]Aliens[/wave]"
var gnoma: String = "[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]Gnoma[/rainbow] x "
var aliens_font = "res://Assets/UI/Fonts/GlitchGoblin/GlitchGoblin.ttf"

var game_start: String = "uid://bb0vxy7wwjwik"
var game_credits: String = "uid://f4o8mclgl0og"

var link_button: TextureButton

@onready var press_audio: AudioStreamPlayer = $PressAudio
@onready var hover_audio: AudioStreamPlayer = $HoverAudio
@onready var theme_audio: AudioStreamPlayer = $ThemeAudio

@onready var title: RichTextLabel = $Panel/HBoxContainer/VBoxContainer/Title
@onready var new_game: Button = $Panel/HBoxContainer/VBoxContainer/ActionsGridContainer/NewGame
@onready var quit: Button = $Panel/HBoxContainer/VBoxContainer/ActionsGridContainer/Quit


func _ready() -> void:
	title.text = gnoma + "[font=%s]" % aliens_font + aliens + "[/font]"
	#theme_audio.play()
	MenuMusic.play_scene_music()


func _on_new_game_pressed() -> void:
	_press_sound()
	MenuMusic.stop()
	EasyTransition.transition_to_path(game_start,1.0,EasyTransition.TransitionAnim.BLUR)


func _on_credits_pressed() -> void:
	_press_sound()
	EasyTransition.transition_to_path(game_credits,1.0,EasyTransition.TransitionAnim.BLUR)


func _on_quit_pressed() -> void:
	_disable_buttons()
	await _press_sound()
	
	if OS.has_feature("web"):
		OS.shell_open("https://gamelabuerj.itch.io/")
	else:
		get_tree().quit()


func _on_instagram_button_pressed() -> void:
	_press_sound()
	OS.shell_open("https://www.instagram.com/gamelab.uerj/")


func _on_itch_button_pressed() -> void:
	_press_sound()
	OS.shell_open("https://gamelabuerj.itch.io/")


func _on_discord_button_pressed() -> void:
	_press_sound()
	OS.shell_open("https://discord.gg/z8qdqPZfE")


func _on_mouse_entered() -> void:
	if hover_audio == null:
		return
		
	hover_audio.play()
	await hover_audio.finished


func _on_mouse_entered_links(button_path: NodePath) -> void:
	if hover_audio == null:
		return

	link_button = get_node(button_path)
	link_button.modulate = Color(1.0, 1.0, 1.0, 0.463)
	
	hover_audio.play()
	await hover_audio.finished


func _on_mouse_exited_links(button_path: NodePath) -> void:
	link_button = get_node(button_path)
	link_button.modulate = Color(1.0, 1.0, 1.0)


func _press_sound() -> void:
	if press_audio == null:
		return
		
	press_audio.play()
	await get_tree().create_timer(0.35).timeout


func _disable_buttons() -> void:
	new_game.disabled = true
	quit.disabled = true
