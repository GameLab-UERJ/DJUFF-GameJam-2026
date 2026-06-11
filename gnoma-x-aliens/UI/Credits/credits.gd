extends Control


var aliens: String = "[wave amp=50]Aliens[/wave]"
var gnoma: String = "[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]Gnoma[/rainbow] x "
var aliens_font = "res://Assets/UI/Fonts/GlitchGoblin/GlitchGoblin.ttf"

var main_menu: String = "uid://d4b7cvgy38tpi"

@onready var press_audio: AudioStreamPlayer = $PressAudio
@onready var hover_audio: AudioStreamPlayer = $HoverAudio

@onready var title: RichTextLabel = $Panel/HBoxContainer/VBoxContainer/Title
@onready var credits: RichTextLabel = $Panel/HBoxContainer/VBoxContainer/Credits

@onready var return_button: Button = $Panel/HBoxContainer/VBoxContainer/ActionsGridContainer/ReturnButton


func _ready() -> void:
	title.text = "Developed by " + "[font=%s]"  % aliens_font + "GameLAb UERJ[/font]:"

	credits.text = \
	"[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]" + "Coordinator: " + "[/rainbow]" +\
	"[font=%s]"  % aliens_font + "\nProfessor Gabriel Carvalho" + "[/font]" +\
	
	"[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]" + "\n\nArt: " + "[/rainbow]" + \
	"[font=%s]"  % aliens_font + "\nFelipe Mello" + "[/font]" + \
	
	"[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]" + "\n\nProgrammers: "  + "[/rainbow]" +\
	"[font=%s]"  % aliens_font + "\nDouglas Carvalho \nIgor Amaral \nJoão Pedro Lomba " +\
	"\nLuiz Fernando Coelho \nThiago Souza" + "[/font]" 
	
	MenuMusic.play_scene_music()


func _on_return_button_pressed() -> void:
	EasyTransition.transition_to_path(main_menu,1.0,EasyTransition.TransitionAnim.BLUR)
	_press_sound()


func _press_sound() -> void:
	if press_audio == null:
		return
		
	press_audio.play()
	await get_tree().create_timer(0.35).timeout


func _on_return_button_mouse_entered() -> void:
	if hover_audio == null:
		return
	
	hover_audio.play()
	await hover_audio.finished
