extends Node2D

@onready var player = $Player
@onready var enemy = $Enemy
@onready var respawn_timer = $RespawnTimer

var player_spawn_pos


#Game Functions
func _ready():
	player_spawn_pos = player.position
	#Hnadle Signals
	Events.connect("shoot", fire_bullet)
	Events.connect("respawn_player", respawn_player)
	
func _process(delta):
	pass
	
#Custom Functions
func fire_bullet(bullet_scene, bullet_position):
	var new_bullet = bullet_scene.instantiate()
	new_bullet.position = bullet_position
	add_child(new_bullet)

func respawn_player():
	var player_instance = load("res://Scenes/player.tscn")
	var new_player = player_instance.instantiate()
	new_player.position = player_spawn_pos
	await Events.timer(1)
	add_child(new_player)
