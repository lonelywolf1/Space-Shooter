extends Node2D

@onready var player = $Player
@onready var camera = $Camera2D
@onready var enemies = $Enemies


var player_spawn_pos

var blast_scene := preload("res://Scenes/World/blast.tscn")
var player_instance := preload("res://Scenes/Player/player.tscn")
var boss_scene := preload("res://Scenes/Enemies/boss.tscn")

var loaded := false
var is_boss_dead := false

const boss_position := Vector2(584, 123)

#Game Functions
func _ready():
	player_spawn_pos = player.position
	#Hnadle Signals
	Events.connect("shoot", fire_bullet)
	Events.connect("respawn_player", respawn_player)
	Events.connect("shake_camera", camera_shake)
	Events.connect("blast", create_blast)
	
func _process(delta):
	if enemies.next_level == null and Events.enemies_left == 0:
		if is_boss_dead:
			await Events.timer(2)
			get_tree().change_scene_to_packed(load("res://Scenes/game_over.tscn"))
		else: 
			var new_boss = boss_scene.instantiate()
			new_boss.position = boss_position
			add_child(new_boss)
			print("THE BOSS!!!")
			
	if Events.enemies_left == 0:
		var new_enemies = enemies.next_level.instantiate()
		new_enemies.position = enemies.position
		add_child(new_enemies)
		enemies.queue_free()
		enemies = new_enemies
		
	
#Custom Functions
func fire_bullet(bullet_scene, bullet_position, bullet_rotation=0.0, is_player=false):
	var new_bullet = bullet_scene.instantiate()
	new_bullet.position = bullet_position
	
	var rot_flip = 0
	if not is_player:
		rot_flip = 180
	else:
		rot_flip = 0
		
	new_bullet.rotation = bullet_rotation - deg_to_rad(rot_flip)
	add_child(new_bullet)

func respawn_player():
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
