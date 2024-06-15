extends Area2D

@export var shot_speed = 20

func _process(delta):
	position.y += shot_speed

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
