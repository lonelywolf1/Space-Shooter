class_name Enemy
extends CharacterBody2D

var enemy_dead = false

var enemy_bullet : PackedScene = preload("res://Scenes/Enemies/enemy_shot.tscn")
var functions = Functions.new()
var index := 0
var enemy_hp = StatsFramework.enemy_hp

@onready var shotDetector = $CollisionPolygon2D/ShotSignal
@onready var timer = $Timer
@onready var animation_shoot = $AnimationShoot
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var cpu_particles_2d = $CPUParticles2D
@onready var skin_picker = $CollisionPolygon2D/SkinPicker
@onready var sprite_2d = skin_picker.current_skin

@export var shoot_sounds:Array[AudioStream]


func _ready():
	start_timer()
	$IdleFloating.speed_scale = randf_range(0.3,0.8)
	Events.enemies_left += 1
	var destination = position
	position.x = randi_range(-400, 400)
	position.y = randi_range(-300, -550)
	while position.distance_to(destination) > 1:
		position.x = lerp(position.x, destination.x, 0.05)
		position.y = lerp(position.y, destination.y, 0.05)
		await Events.timer(0.01)
		
func _process(delta):
	if Events.player != null:
		var angle_to_zero = global_position.angle_to_point(Events.player.position)
		rotation = lerp_angle(rotation, angle_to_zero - deg_to_rad(90), 0.035)
	
func enemy_shotted(amount : int):
	if enemy_dead:
		return
		
	enemy_hp -= amount
	if enemy_hp <= 0:
		die()
	
	Events.shake_camera.emit(randi_range(4, 6), 3.0, 1.5) #emitting signal to shake the camera on Level script
	$Hit1.pitch_scale = randf_range(0.8,1.3)
	$Hit2.pitch_scale = randf_range(0.8,1.3)
	$Hit1.play()
	$Hit2.play()

func die():
	enemy_dead = true
	cpu_particles_2d.emitting = true
	SoundPlayer.crash.play()
	Events.enemies_left -= 1
	
	if collision_polygon_2d != null:
		collision_polygon_2d.queue_free()
	if is_instance_valid(sprite_2d):
		sprite_2d.visible = false
	await cpu_particles_2d.finished
	queue_free()
	
func start_timer():
	timer.wait_time = randf_range(0.5, 2.5)
	timer.start()


func _on_shot_signal_area_entered(area):
	var hp_amount = StatsFramework.enemy_damage
	area.done()
	Events.blast.emit(area.position)
	enemy_shotted(hp_amount)


func _on_timer_timeout():
	if enemy_dead or Events.player == null:
		return
	
	Events.shoot.emit(enemy_bullet, global_position, rotation)
	animation_shoot.play("shoot")
	functions.playSounds(index, $Shoot, shoot_sounds)
	
	start_timer()
  
