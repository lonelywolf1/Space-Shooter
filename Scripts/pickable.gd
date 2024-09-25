extends Area2D

@export var upgrade :Array[UpgradeModule]
var currentUpgrade:UpgradeModule

@onready var speed: Sprite2D = $Speed
@onready var damage: Sprite2D = $Damage
@onready var firerate: Sprite2D = $Firerate
@onready var health: Sprite2D = $Health


func _ready():
	currentUpgrade = upgrade[randi_range(0, upgrade.size()-1)]
	
	# handling sprites
	speed.hide()
	damage.hide()
	firerate.hide()
	health.hide()
	if currentUpgrade.type == "speed":
		speed.show()
	elif currentUpgrade.type == "damage":
		damage.show()
	elif currentUpgrade.type == "fire_rate":
		firerate.show()
	elif currentUpgrade.type == "health":
		health.show()
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not body.player_dead:
		body.apply_upgrade(currentUpgrade)
		if currentUpgrade.isTemporary:
			Events.upgrade_pickup_temporary.emit(currentUpgrade)
			
		Events.new_upgrade.emit()
		queue_free()
	
 
