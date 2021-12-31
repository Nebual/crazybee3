extends Node

# eg. limit = 0.95 means you'll get a random number between -0.95 and 0.95
func rand_signed_float(limit):
	return (randf() * limit * 2) - limit

var audio_player_oneoff = preload("res://AudioPlayerOneOff.tscn")

func play_sound(sound, volume=0, offset=0, pitch=1):
	var sound_emitter : AudioStreamPlayer = audio_player_oneoff.instance()
	sound_emitter.stream = sound
	sound_emitter.volume_db = volume
	sound_emitter.pitch_scale = pitch
	sound_emitter.play(offset)
	$"/root/Main".add_child(sound_emitter)
