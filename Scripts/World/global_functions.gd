class_name Functions
extends Resource

func kill_shot(shot_handle, sprite2d, collision, particles):
	sprite2d.visible = false
	if is_instance_valid(collision) and collision != null:
		collision.queue_free()
	particles.emitting = false
	await particles.finished
	shot_handle.queue_free()

func playSounds(index, soundplayer, sound_list):
	if index > sound_list.size()-1:
		index = 0
		sound_list.shuffle()
	
	soundplayer.stream = sound_list[index]
	index += 1
	soundplayer.pitch_scale = randf_range(0.9,1.2)
	soundplayer.play()
