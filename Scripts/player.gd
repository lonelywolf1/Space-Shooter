extends CharacterBody2D


var keyboard_input_x
var keyboard_input_y
var bullet_shot_scene : PackedScene = preload("res://Scenes/player_shot.tscn")

var player_hp = 3
var is_invincible : bool = false
var player_dead : bool = false

const player_speed = 50

@onready var animation_shoot = $Animation_shoot
@onready var cpu_particles_2d = $CPUParticles2D
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var sprite_2d = $CollisionPolygon2D/Sprite2D

func _process(delta):
	keyboard_input_x = Input.get_axis("ui_left", "ui_right")
	keyboard_input_y = Input.get_axis("ui_up", "ui_down")
	var p_direction = Vector2(keyboard_input_x, keyboard_input_y).normalized() #getting Axis direction & normalizing to pixel moving
	
	velocity += p_direction * player_speed
	
	apply_friction_onplayer()
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept") and !player_dead:
		Events.shoot.emit(bullet_shot_scene, position, true)
		animation_shoot.play("shoot")
	
func apply_friction_onplayer():
	velocity *= 0.96

func player_hit(amount):
	if player_dead:
		return
		
	player_hp -= amount
	if player_hp <= 0:
		kill_player()
		
	give_invincibility()
	Events.shake_camera.emit(randi_range(5, 7), 5.0, 3.0)
		
func give_invincibility():
	is_invincible = true
	$AnimationPlayer.play("invincible")
	await Events.timer(0.5)
	is_invincible = false
	$AnimationPlayer.play("RESET")
	
func kill_player():
	if player_dead:
		return
		
	player_dead = true
	cpu_particles_2d.emitting = true
	collision_polygon_2d.disabled = true
	sprite_2d.visible = false
	await cpu_particles_2d.finished
	Events.respawn_player.emit()
	queue_free()

func _on_bullet_detector_area_entered(area):
	Events.blast.emit(area.position)
	area.done()
	if not is_invincible:
		player_hit(1)
