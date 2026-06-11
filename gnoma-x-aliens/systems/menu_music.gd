extends AudioStreamPlayer

const menu_music = preload("uid://rm0u1kbm1oxv")

func _play_music(music: AudioStream, volume : float = 0) -> void:
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()

func play_scene_music(music : AudioStream = menu_music, volume : float = 0) -> void:
	_play_music(music, volume)
