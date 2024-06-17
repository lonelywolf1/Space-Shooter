extends Area2D

@export var shot_speed = 20

var functions = Functions.new()

func _process(delta):
	position.y += -shot_speed

func _on_visible_on_screen_notifier_2d_screen_exited():
	if has_node("CollisionPolygon2D"):
		done()

func done():
	functions.kill_shot(self, $Sprite2D, $CollisionPolygon2D, $CPUParticles2D)
 
