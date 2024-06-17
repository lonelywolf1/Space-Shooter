extends Area2D

@export var shot_speed = 5

func _process(delta):
	var direction = Vector2.UP.rotated(rotation)
	position += shot_speed*direction

func _on_visible_on_screen_notifier_2d_screen_exited():
	done()

func done():
	$Sprite2D.visible = false
	if $CollisionPolygon2D != null:
		$CollisionPolygon2D.queue_free()
	$CPUParticles2D.emitting = false
	await $CPUParticles2D.finished
	queue_free()
