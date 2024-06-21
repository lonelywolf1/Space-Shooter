extends Area2D

@export var shot_speed = 5

var functions = Functions.new()

func _process(delta):
	var direction = Vector2.UP.rotated(rotation)
	position += shot_speed*direction * (100*delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	if has_node("CollisionPolygon2D"):
		done()

func done():
	functions.kill_shot(self, $Sprite2D, $CollisionPolygon2D, $CPUParticles2D)
