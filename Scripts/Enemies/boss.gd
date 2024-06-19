extends CharacterBody2D

var asteroid_scene = preload("res://Scenes/Enemies/asteroid.tscn")
@onready var timer = $Timer

var isAlive := false

var index := 0
@export var shoot_sounds : Array[AudioStream]
@export var health:HealthComponent

func _ready():
	start_timer()
	Events.enemies_left = 1
	Events.connect("hurt_boss", hurt_boss)
	Events.connect("blast_boss", func():
		$Explosion.emitting = true
	)
	
	#going into the scene
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
		rotation = lerp_angle(rotation, angle_to_zero - deg_to_rad(90), 0.05)
		
func _on_timer_timeout():
	if isAlive or Events.player == null:
		return
	
	if randi_range(0, 1):
		for i in 3:
			var pos 
			match i:
				0:
					pos = position
				1:
					pos = Vector2(position.x+75, position.y)
				2:
					pos = Vector2(position.x-75, position.y)
			await Events.timer(0.03)
			Events.shoot.emit(asteroid_scene, pos, rotation, false)
	else:
		Events.shoot.emit(asteroid_scene, position, rotation, false)
		
	start_timer()
	
	Functions.new().playSounds(index, $Shoot, shoot_sounds)
	
	start_timer()

func start_timer():
	timer.wait_time = randf_range(1.0, 2.5)
	timer.start()


func boss_shotted(amount : int):
	if isAlive:
		return
		
	health.take_damage(amount)
	if health.get_health_ratio() <= 0:
		die()
	
	Events.shake_camera.emit(randi_range(6, 8), 3.0, 1.5) #emitting signal to shake the camera on Level script
	$Hit1.pitch_scale = randf_range(0.8,1.3)
	$Hit2.pitch_scale = randf_range(0.8,1.3)
	$Hit1.play()
	$Hit2.play()

func hurt_boss():
	var hp = randi_range(10, health.current_health/2)
	boss_shotted(hp)
	
func die():
	if isAlive:
		return
		
	isAlive = false
	health.toggleHealthBar(false)
	$ShotSignal.queue_free()
	$Explosion.emitting = true
	await $Explosion.finished
	Events.boss_dead.emit()
	queue_free()

func _on_shot_signal_area_entered(area):
	var hp_decrease = 1
	$Explosion.emitting = true
	boss_shotted(hp_decrease)
