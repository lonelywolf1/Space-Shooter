extends CharacterBody2D
class_name Player

var keyboard_input_x
var keyboard_input_y
var bullet_shot_scene : PackedScene = preload("res://Scenes/Player/player_shot.tscn")
var functions = Functions.new()

var is_invincible : bool = false
var player_dead : bool = false
var player_shooting : bool = false
var index := 0 
var isControlled := false
var asteroid_node:CharacterBody2D
var enemy_damage := randi_range(10,25)

const player_speed = 50

@export_category("Player Variables")
@export var SHOOTING_SPEED = 0.2
@export var shoot_sounds:Array[AudioStream]
@export var health:HealthComponent

@onready var animation_shoot = $Animation_shoot
@onready var cpu_particles_2d = $CPUParticles2D
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var sprite_2d = $CollisionPolygon2D/Sprite2D
@onready var right_jet = $CollisionPolygon2D/Sprite2D/Right_Jet
@onready var left_jet = $CollisionPolygon2D/Sprite2D/Left_Jet
@onready var back_jet = $CollisionPolygon2D/Sprite2D/Back_jet
@onready var front_jets = $CollisionPolygon2D/Sprite2D/Front_Jets
@onready var controller_timer = $ControllerTimer

var right_jet_max
var left_jet_max
var back_jet_max
var front_jets_max

func _ready():
	Events.player = self
	Events.connect("destroy_asteroid_controlled", destroyAsteroid)
	Events.connect("shoot_touch", func():
		shoot()
		)
	right_jet_max = right_jet.scale.y
	left_jet_max = left_jet.scale.y
	back_jet_max = back_jet.scale.y
	front_jets_max = front_jets.scale.y
	right_jet.scale.y = 0
	left_jet.scale.y = 0
	back_jet.scale.y = 0
	front_jets.scale.y = 0
	isControlled = true


func _process(delta):
	if isControlled:
		keyboard_input_x = Input.get_axis("ui_left", "ui_right")
		keyboard_input_y = Input.get_axis("ui_up", "ui_down")
		var p_direction = Vector2(keyboard_input_x, keyboard_input_y).normalized() #getting Axis direction & normalizing to pixel moving
		
		velocity += p_direction * player_speed
		
		move_and_slide()
	apply_friction_onplayer()
	animate_player_jets()
	engine_sound()
	
	if Input.is_action_pressed("ui_accept") and !player_dead and !player_shooting: #checking player isn't dead and not shooting
		shoot()
		
	if Input.is_action_just_pressed("Interaction") and not player_dead:
		controlAsteroid(5)

func _on_bullet_detector_area_entered(area):
	if is_invincible:
		return
		
	var hp_decrease = 0
	if area.is_in_group("asteroid"):
		area.get_parent().done()
		hp_decrease = health.current_health
		Events.blast.emit(area.get_parent().position)
	else:
		Events.blast.emit(area.position)
		hp_decrease = enemy_damage
		area.done()
		
	player_hit(hp_decrease)
		
func engine_sound():
	$Engine.volume_db = velocity.length()/50-25

func shoot():
	player_shooting = true #need to check for automatic shoot
	Events.shoot.emit(bullet_shot_scene, position, rotation, true)
	animation_shoot.play("shoot")
	functions.playSounds(index, $Shoot, shoot_sounds)
	
	await Events.timer(SHOOTING_SPEED)
	player_shooting = false
	
func apply_friction_onplayer():
	velocity *= 0.96

func controlAsteroid(time):
	asteroid_node = get_tree().get_first_node_in_group("asteroid")
	
	if asteroid_node == null or not asteroid_node.sprite_2d.visible or not isControlled:
		return
		
	asteroid_node.isControlled = true
	Events.controlling_asteroid = true
	Events.control_asteroid.emit(true)
	asteroid_node.shot_signal.set_collision_layer_value(4, false)
	asteroid_node.shot_signal.set_collision_mask_value(4, true)
	isControlled = false
	give_invincibility(time)
	controller_timer.wait_time = time
	controller_timer.start()
	
func destroyAsteroid(asteroid):
	give_invincibility(0)
	isControlled = true
	controller_timer.stop()
	if asteroid_node != null:
		functions.kill_shot(asteroid, asteroid.sprite_2d, asteroid.collision, asteroid.particles)
		
	Events.control_asteroid.emit(false)

func player_hit(amount):
	if player_dead:
		return
		
	health.take_damage(amount)
	if health.get_health_ratio() <= 0 and has_node("CollisionPolygon2D"):
		SoundPlayer.crash.play()
		kill_player()
		
	give_invincibility(0.5)
	Events.shake_camera.emit(randi_range(5, 7), 5.0, 3.0)
	$Hit1.pitch_scale = randf_range(0.8,1.3)
	$Hit2.pitch_scale = randf_range(0.8,1.3)
	$Hit1.play()
	$Hit2.play()
		
func give_invincibility(time):
	is_invincible = true
	$AnimationPlayer.play("invincible")
	await Events.timer(time)
	is_invincible = false
	$AnimationPlayer.play("RESET")
	
func kill_player():
	if player_dead:
		return
		
	player_dead = true
	cpu_particles_2d.emitting = true
	collision_polygon_2d.disabled = true
	sprite_2d.visible = false
	health.toggleHealthBar(false)
	await cpu_particles_2d.finished
	Events.respawn_player.emit()
	Events.TOTAL_PLAYER_HEALTH -= 1
	Events.kill_player.emit()
	if Events.TOTAL_PLAYER_HEALTH <= 0:
		get_tree().change_scene_to_packed(load("res://Scenes/World/game_over.tscn"))
	queue_free()

func animate_player_jets():
	animate_single_jet(right_jet, right_jet_max, keyboard_input_x, -1)
	animate_single_jet(left_jet, left_jet_max, keyboard_input_x, 1)
	animate_single_jet(back_jet, back_jet_max, keyboard_input_y, -1)
	animate_single_jet(front_jets, front_jets_max, keyboard_input_y, 1)

func animate_single_jet(jet, destination, input, condition):
	if input == condition:
		jet.scale.y = lerpf(jet.scale.y, destination, 0.05)
	else:
		jet.scale.y = lerpf(jet.scale.y, 0, 0.05)


func _on_controller_timer_timeout():
	if asteroid_node != null:
		asteroid_node.isControlled = false
		Events.controlling_asteroid = false
	isControlled = true
	Events.control_asteroid.emit(false)
