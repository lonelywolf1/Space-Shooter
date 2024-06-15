extends Area2D

@export var shot_speed = 20

func _process(delta):
	position.y += shot_speed

func _on_visible_on_screen_notifier_2d_screen_exited():
	done()

func done():
	$Sprite2D.visible = false
	$CollisionPolygon2D.disabled = true
	$CPUParticles2D.emitting = false
	await $CPUParticles2D.finished
	queue_free()
