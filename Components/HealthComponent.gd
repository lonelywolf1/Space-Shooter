class_name HealthComponent
extends Node2D

@export var max_health:int = 100
@export var current_health:int = 20
@export var damage_to_take:int = 1

signal health_changed(current_health)

@onready var health_bar = $HealthBar

func _ready():
	health_bar.min_value = 0
	health_bar.max_value = max_health
	update_health()
	toggleHealthBar(false)
	
func _process(delta):
	if get_health_ratio() < 0.9 && !health_bar.visible && current_health != 0:
		toggleHealthBar(true)
	
func take_damage(amount: int):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	update_health()
	
func give_hp(amount: int):
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
	update_health()
	
func get_health_ratio() -> float:
	return current_health / float(max_health)

func update_health():
	health_bar.value = current_health
	health_changed.emit(current_health)
	
func toggleHealthBar(state: bool):
	health_bar.visible = state
