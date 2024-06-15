extends CharacterBody2D


var keyboard_input_x
var keyboard_input_y
var bullet_shot_scene : PackedScene = preload("res://Scenes/player_shot.tscn")

var player_hp = 3
var is_invincible : bool = false

const player_speed = 50

func _process(delta):
	keyboard_input_x = Input.get_axis("ui_left", "ui_right")
	keyboard_input_y = Input.get_axis("ui_up", "ui_down")
	var p_direction = Vector2(keyboard_input_x, keyboard_input_y).normalized() #getting Axis direction & normalizing to pixel moving
	
	velocity += p_direction * player_speed
	
	apply_friction_onplayer()
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		Events.shoot.emit(bullet_shot_scene, position, true)
	
func apply_friction_onplayer():
	velocity *= 0.96

func player_hit(amount):
		player_hp -= amount
		if player_hp <= 0:
			kill_player()
			
		give_invincibility()
		Events.shake_camera.emit(randi_range(4, 6), 3.0, 2.0)
		
func give_invincibility():
	is_invincible = true
	$AnimationPlayer.play("invincible")
	await Events.timer(0.5)
	is_invincible = false
	$AnimationPlayer.play("RESET")
	
func kill_player():
		Events.respawn_player.emit()
		queue_free()

func _on_bullet_detector_area_entered(area):
	area.queue_free()
	if not is_invincible:
		player_hit(1)
