extends Node2D

var enemy_damage:int = 1
var player_speed:int = 50
var player_shooting_speed:float = 0.15
var player_damage_min:int = 10
var player_damage_max:int = 25
var enemy_hp:int = 3
var asteroid_speed:int = 60

@export_category("Maximum Values")
@export var max_firerate = 0.01
@export var max_damage = 50
@export var max_speed = 100

#Optional signals if needed!

signal update_player_damage
signal update_player_speed
signal update_player_firerate
#signal update_enemy_damage
#signal update_enemy_hp
	


func updateEnemyDamage(amount:int = 1):
	enemy_damage = amount
	
func updatePlayerSpeed(amount:int = 50):
	player_speed = amount
	update_player_speed.emit(player_speed)

func updatePlayerShootingspeed(amount:float = 0.15):
	player_shooting_speed = amount
	update_player_firerate.emit(player_shooting_speed)
	
func updatePlayerDamage(amount_min:int = 10, amount_max:int = 25):
	player_damage_min = amount_min
	player_damage_max = amount_max
	update_player_damage.emit(player_damage_min, player_damage_max)

func getPlayerDamage():
	return randi_range(player_damage_min, player_damage_max)

#Upgrade Module Handler

func applyTemporaryUpgrades(upgrade: UpgradeModule):
	if upgrade.type == "fire_rate":
		var current_firerate = player_shooting_speed
		var upgraded_firerate = (current_firerate + upgrade.impact) * upgrade.multiplier
		if upgraded_firerate <= max_firerate: 
			print("Max Firerate Achieved!")
			upgraded_firerate = max_firerate
		updatePlayerShootingspeed(upgraded_firerate)
		print("Firerate Upgraded +", upgrade.impact)
		await Events.timer(upgrade.duration)
		updatePlayerShootingspeed(current_firerate)
		print("Upgrade removed")
	elif upgrade.type == "damage":
		var current_min_damage = player_damage_min
		var current_max_damage = player_damage_min
		var upgraded_min_damage = (current_min_damage + upgrade.impact) * upgrade.multiplier
		var upgraded_max_damage = (current_max_damage + upgrade.impact) * upgrade.multiplier
		if upgraded_max_damage >= max_damage: 
			print("Max Damage Achieved!")
			upgraded_max_damage = max_damage
		updatePlayerDamage(upgraded_min_damage, upgraded_max_damage)
		print("damage upgraded, +", upgrade.impact)
		await Events.timer(upgrade.duration)
		updatePlayerDamage(current_min_damage, current_max_damage)
		print("Upgrade removed")
	elif upgrade.type == "speed":
		var current_speed = player_speed
		var upgraded_speed = (current_speed + upgrade.impact) * upgrade.multiplier
		if upgraded_speed >= max_speed: 
			print("Max Speed Achieved!")
			upgraded_speed = max_speed
		updatePlayerSpeed(upgraded_speed)
		print("Speed upgraded, +", upgrade.impact)
		await Events.timer(upgrade.duration)
		updatePlayerSpeed(current_speed)
		print("Upgrade removed")
	
	print("Upgrade: " + upgrade.type + " Upgraded!")
	
func applyPermanentUpgrades(upgrade: UpgradeModule):
	if upgrade.type == "fire_rate":
		var current_firerate = player_shooting_speed
		var upgraded_firerate = (current_firerate + upgrade.impact) * upgrade.multiplier
		
		if upgraded_firerate <= max_firerate: 
			print("Max Firerate Achieved!")
			return 
		
		updatePlayerShootingspeed(upgraded_firerate)
		print("Firerate Upgraded +", upgrade.impact, " Permanently")
	elif upgrade.type == "damage":
		var current_min_damage = player_damage_min
		var current_max_damage = player_damage_min
		var upgraded_min_damage = (current_min_damage + upgrade.impact) * upgrade.multiplier
		var upgraded_max_damage = (current_max_damage + upgrade.impact) * upgrade.multiplier
		if upgraded_max_damage >= max_damage: 
			print("Max Damage Achieved!")
			return 
		updatePlayerDamage(upgraded_min_damage, upgraded_max_damage)
		print("Damage Upgraded +", upgrade.impact, " Permanently")
	elif upgrade.type == "speed":
		var current_speed = player_speed
		var upgraded_speed = (current_speed + upgrade.impact) * upgrade.multiplier
		
		if upgraded_speed >= max_speed: 
			print("Max Speed Achieved!")
			return 
			
		updatePlayerSpeed(upgraded_speed)
		print("SPEED Upgraded +", upgrade.impact, " Permanently")
	elif upgrade.type == "health":
		get_tree().get_first_node_in_group("Player").health.give_hp(upgrade.impact * upgrade.multiplier)
