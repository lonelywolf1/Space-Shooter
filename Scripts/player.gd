extends CharacterBody2D


var keyboard_input_x
var keyboard_input_y
var bullet_shot_scene : PackedScene = preload("res://Scenes/player_shot.tscn")

var player_hp = 3
var is_invincible : bool = false
var player_dead : bool = false
var player_shooting : bool = false

const player_speed = 50

@export_category("Player Variables")
@export var SHOOTING_SPEED = 0.3
#@export var TOTAL_HEALTH = 3

@onready var animation_shoot = $Animation_shoot
@onready var cpu_particles_2d = $CPUParticles2D
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var sprite_2d = $CollisionPolygon2D/Sprite2D
@onready var right_jet = $CollisionPolygon2D/Sprite2D/Right_Jet
@onready var left_jet = $CollisionPolygon2D/Sprite2D/Left_Jet
@onready var back_jet = $CollisionPolygon2D/Sprite2D/Back_jet
@onready var front_jets = $CollisionPolygon2D/Sprite2D/Front_Jets

var right_jet_max
var left_jet_max
var back_jet_max
var front_jets_max

func _ready():
	Events.player = self
	right_jet_max = right_jet.scale.y
	left_jet_max = left_jet.scale.y
	back_jet_max = back_jet.scale.y
	front_jets_max = front_jets.scale.y
	right_jet.scale.y = 0
	left_jet.scale.y = 0
	back_jet.scale.y = 0
	front_jets.scale.y = 0

func _process(delta):
	keyboard_input_x = Input.get_axis("ui_left", "ui_right")
	keyboard_input_y = Input.get_axis("ui_up", "ui_down")
	var p_direction = Vector2(keyboard_input_x, keyboard_input_y).normalized() #getting Axis direction & normalizing to pixel moving
	
	velocity += p_direction * player_speed
	
	apply_friction_onplayer()
	animate_player_jets()
	move_and_slide()
	
	if Input.is_action_pressed("ui_accept") and !player_dead and !player_shooting:
		player_shooting = true
		Events.shoot.emit(bullet_shot_scene, position, rotation, true)
		animation_shoot.play("shoot")
		await Events.timer(SHOOTING_SPEED)
		player_shooting = false

func _on_bullet_detector_area_entered(area):
	Events.blast.emit(area.position)
	area.done()
	if not is_invincible:
		player_hit(1)
		
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
