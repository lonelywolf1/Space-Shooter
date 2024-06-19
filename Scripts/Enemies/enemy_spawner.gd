class_name EnemyHandler
extends VBoxContainer

@export var hBoxContainer:HBoxContainer
#@export_range(1, 9) var spawn_amount: int = 3
@onready var enemy_scene: PackedScene = preload("res://Scenes/Enemies/enemy.tscn")

var current_enemies := 0

func spawn_enemies(amount: int):
	for i in range(amount):
		var new_enemy_container = create_enemy_container(i, hBoxContainer)
		
func create_enemy_container(enemy_index: int, enemy_container):
	# Calculate which BoxContainer to use
	var boxContainer = BoxContainer.new()
	enemy_container.add_child(boxContainer)  # Assuming this function is in a Node or Control
	
	var new_enemy = enemy_scene.instantiate()
	boxContainer.add_child(new_enemy)

	current_enemies += 1

func clear_container():
	current_enemies = 0
	for child in hBoxContainer.get_children():
		child.queue_free()
