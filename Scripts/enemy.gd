extends CharacterBody2D

var enemy_hp = 5
var enemy_bullet : PackedScene = preload("res://Scenes/enemy_shot.tscn")

@onready var shotDetector = $"Shot Signal"

signal enemy_died

func _ready():
	$Timer.wait_time = randf_range(0.5, 2.5)
	
func enemy_shotted(amount : int):
	enemy_hp -= amount
	if enemy_hp <= 0:
		queue_free()
		enemy_died.emit()


func _on_shot_signal_area_entered(area):
	const hp_amount = 1
	area.queue_free()
	enemy_shotted(hp_amount)


func _on_timer_timeout():
	Events.shoot.emit(enemy_bullet, position)
	$Timer.wait_time = randf_range(0.5, 2.5)
	$Timer.start()
	
