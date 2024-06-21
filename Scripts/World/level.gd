extends Node2D

@onready var player = $Player
@onready var camera = $Camera2D
@onready var round_number = $CanvasLayer/TOP_RIGHT/RoundNumber

@export var enemies:Array[EnemyHandler]
@export var total_hp_sprites:Array[Sprite2D]
@export var boss_minimum_round:int = 5 #5 def
@export var boss_spawn_chance:int = 20 #20 def

var player_spawn_pos

var blast_scene := preload("res://Scenes/World/blast.tscn")
var player_instance := preload("res://Scenes/Player/player.tscn")
var boss_scene := preload("res://Scenes/Enemies/boss.tscn")

var loaded := false
var functions = Functions.new()
var current_round = 0

const boss_position := Vector2(584, 123)

#Game Functions
func _ready():
	player_spawn_pos = player.position
	#Hnadle Signals
	Events.connect("shoot", fire_bullet)
	Events.connect("respawn_player", respawn_player)
	Events.connect("shake_camera", camera_shake)
	Events.connect("blast", create_blast)
	Events.connect("destroy_asteroid_controlled", func(asteroid_node):
		functions.kill_shot(asteroid_node, asteroid_node.sprite_2d, asteroid_node.collision, asteroid_node.particles)
		Events.controlling_asteroid = false
		)
	Events.connect("boss_dead", func():
		Events.enemies_left = 0
		if Events.TOTAL_PLAYER_HEALTH < 3:
			Events.TOTAL_PLAYER_HEALTH += 1
			for i in Events.TOTAL_PLAYER_HEALTH:
				total_hp_sprites[i].visible = true
		#TODO - Give Ability / Stat Boost
		)
	Events.connect("kill_player",func():
		total_hp_sprites[Events.TOTAL_PLAYER_HEALTH].visible = false
		)
		
	Events.connect("next_round", func():
		current_round += 1
		round_number.text = "ROUND: " + str(current_round)
		)
	
	Events.TOTAL_PLAYER_HEALTH = 3
	
	
func _process(delta):
	#Handling Enemies
	if Events.enemies_left <= 0:
			
		for enemy_container in enemies:
			enemy_container.clear_container() #clears Box Container!
			
		var boss_chance := randi_range(1,100)
		if boss_chance < boss_spawn_chance and current_round >= boss_minimum_round:
			var new_boss = boss_scene.instantiate()
			new_boss.position = boss_position
			add_child(new_boss)
			Events.boss_spawn.emit()
			print("THE BOSS!!!")
		else:
			var random_amount := 0
			if current_round < 10:
				random_amount = randi_range(3, 8)
			elif current_round >= 10:
				random_amount = randi_range(3, 10)
			elif current_round >= 20:
				random_amount = randi_range(4, 15)
			else:
				random_amount = randi_range(2, 13) #DEFAULT
				
			if random_amount > 7:
				for i in range(enemies.size()):
					var amount = random_amount / enemies.size()
					# check amount % random_amount = ?
					if i % 2:
						amount-=1
					else:
						amount+=1
						
					enemies[i].spawn_enemies(amount)
			else:
				enemies[0].spawn_enemies(random_amount)
					
	if Events.round_updated and Events.enemies_left > 0:
		Events.round_updated = false
	
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
