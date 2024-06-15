extends Node2D

@onready var player = $Player
@onready var enemy = $Enemy
@onready var camera = $Camera2D

var player_spawn_pos

var blast_scene : PackedScene = preload("res://Scenes/blast.tscn")


#Game Functions
func _ready():
	player_spawn_pos = player.position
	#Hnadle Signals
	Events.connect("shoot", fire_bullet)
	Events.connect("respawn_player", respawn_player)
	Events.connect("shake_camera", camera_shake)
	Events.connect("blast", create_blast)
	
func _process(delta):
	pass
	
#Custom Functions
func fire_bullet(bullet_scene, bullet_position, is_player=false):
	var new_bullet = bullet_scene.instantiate()
	new_bullet.position = bullet_position
	add_child(new_bullet)

func respawn_player():
	var player_instance = load("res://Scenes/player.tscn")
	var new_player = player_instance.instantiate()
	new_player.position = player_spawn_pos
	await Events.timer(1)
	add_child(new_player)

func camera_shake(shake_amount, rangeX:float, rangeY:float):
	for i in shake_amount:
		var camera_x_shake = randf_range(-rangeX, rangeX)
		var camera_y_shake = randf_range(-rangeY, rangeY)
		camera.offset = Vector2(camera_x_shake, camera_y_shake)
		if i+1 == shake_amount:
			camera.offset = Vector2.ZERO
			
		await Events.timer(0.02)
		
func create_blast(blast_position):
	var new_blast = blast_scene.instantiate()
	new_blast.position = blast_position
	add_child(new_blast)
