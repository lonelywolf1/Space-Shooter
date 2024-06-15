extends CharacterBody2D

var enemy_hp = 5
var enemy_bullet : PackedScene = preload("res://Scenes/enemy_shot.tscn")
var enemy_dead = false

@onready var shotDetector = $ShotSignal
@onready var timer = $Timer
@onready var animation_shoot = $AnimationShoot
@onready var sprite_2d = $CollisionPolygon2D/Sprite2D
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var cpu_particles_2d = $CPUParticles2D

func _ready():
	start_timer()
	$IdleFloating.speed_scale = randf_range(0.3,0.8)
	
func enemy_shotted(amount : int):
	if enemy_dead:
		return
		
	enemy_hp -= amount
	if enemy_hp <= 0:
		die()
	
	Events.shake_camera.emit(randi_range(4, 6), 3.0, 1.5) #emitting signal to shake the camera on Level script

func die():
	enemy_dead = true
	cpu_particles_2d.emitting = true
	collision_polygon_2d.disabled = true
	sprite_2d.visible = false
	await cpu_particles_2d.finished
	queue_free()
	
func start_timer():
	timer.wait_time = randf_range(0.5, 2.5)
	timer.start()


func _on_shot_signal_area_entered(area):
	const hp_amount = 1
	Events.blast.emit(area.position)
	area.done()
	enemy_shotted(hp_amount)


func _on_timer_timeout():
	if enemy_dead:
		return
		
	Events.shoot.emit(enemy_bullet, position)
	animation_shoot.play("shoot")
	start_timer()
  
