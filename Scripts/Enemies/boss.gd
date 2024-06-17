extends CharacterBody2D

var asteroid_scene = preload("res://Scenes/Enemies/asteroid.tscn")
@onready var timer = $Timer

var dead := false
var health := 30

var index := 0
@export var shoot_sounds : Array[AudioStream]

func _ready():
	start_timer()
	Events.enemies_left = 1
	Events.connect("hurt_boss", hurt_boss)
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
		rotation = lerp_angle(rotation, angle_to_zero - deg_to_rad(90), 0.02)
		
func _on_timer_timeout():
	if dead or Events.player == null:
		return
		
	Events.shoot.emit(asteroid_scene, position, rotation, false)
	start_timer()
	
	if index > shoot_sounds.size()-1:
		index = 0
		shoot_sounds.shuffle()

	$Shoot.stream = shoot_sounds[index]
	index += 1
	$Shoot.pitch_scale = randf_range(0.9,1.2)
	$Shoot.play()
	$Shooting.play("shoot")
	start_timer()

func start_timer():
	timer.wait_time = randf_range(1.0, 2.5)
	timer.start()


func boss_shotted(amount : int):
	if dead:
		return
		
	health -= amount
	if health <= 0:
		die()
	
	Events.shake_camera.emit(randi_range(6, 8), 3.0, 1.5) #emitting signal to shake the camera on Level script
	$Hit1.pitch_scale = randf_range(0.8,1.3)
	$Hit2.pitch_scale = randf_range(0.8,1.3)
	$Hit1.play()
	$Hit2.play()

func hurt_boss():
	var hp = randi_range(2, health)
	boss_shotted(hp)
	
func die():
	if dead:
		return
		
	dead = true
	Events.end_game.emit()
	$ShotSignal.monitoring = false
	$ShotSignal.monitorable = false
	$ShotSignal/CollisionPolygon2D.disabled = true
	$ShotSignal/CollisionPolygon2D/Sprite2D.visible = false
	$Explosion.emitting = true
	await $Explosion.finished
	queue_free()

func _on_shot_signal_area_entered(area):
	var hp_decrease = 1
	Events.blast.emit(area.position)
	boss_shotted(hp_decrease)
