extends Node2D

var enemy_damage:int = 1
var player_speed:int = 50
var player_shooting_speed:float = 0.15
var player_damage_min:int = 10
var player_damage_max:int = 25
var enemy_hp:int = 3
var asteroid_speed:int = 60

#Optional signals if needed!

#signal update_player_damage
#signal update_player_speed
#signal update_player_shootingspeed
#signal update_enemy_damage
#signal update_enemy_hp


func updateEnemyDamage(amount:int = 1):
	enemy_damage = amount
	
func updatePlayerSpeed(amount:int = 50):
	player_speed = amount

func updatePlayerShootingspeed(amount:float = 0.15):
	player_shooting_speed = amount
	
func updatePlayherDamage(amount_min:int = 10, amount_max:int = 25):
	player_damage_min = amount_min
	player_damage_max = amount_max

func getPlayerDamage():
	return randi_range(player_damage_min, player_damage_max)
