extends CharacterBody2D

var speed := randi_range(7,10)

func done():
	$Sprite2D.visible = false
	if $CollisionPolygon2D != null:
		$CollisionPolygon2D.queue_free()
	$FloatParticles.emitting = false
	await $FloatParticles.finished
	queue_free()
	
	

func _process(delta):
	var direction = Vector2.UP.rotated(rotation)
	position += speed * direction


func _on_visible_on_screen_notifier_2d_screen_exited():
	done()

