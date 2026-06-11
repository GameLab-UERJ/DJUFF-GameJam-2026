extends AudioStreamPlayer

const menu_music = preload("uid://rm0u1kbm1oxv")

func _play_music(music: AudioStream) -> void:
	if stream == music:
		return
	
	stream = menu_music
	play()

func play_scene_music() -> void:
	_play_music(menu_music)
